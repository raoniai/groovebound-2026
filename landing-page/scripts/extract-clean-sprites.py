#!/usr/bin/env python3
"""Extract complete transparent sprites from generated atlases.

The source atlases are not strict sprite sheets: several subjects extend past
their nominal grid cell. Fixed cell crops therefore include pieces of adjacent
subjects and clip the intended sprite. This extractor groups alpha-connected
components around each major subject, then normalizes every complete subject
onto a square transparent canvas.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]


@dataclass
class Component:
    pixels: list[tuple[int, int]] = field(default_factory=list)
    min_x: int = 10**9
    min_y: int = 10**9
    max_x: int = -1
    max_y: int = -1

    def add(self, x: int, y: int) -> None:
        self.pixels.append((x, y))
        self.min_x = min(self.min_x, x)
        self.min_y = min(self.min_y, y)
        self.max_x = max(self.max_x, x)
        self.max_y = max(self.max_y, y)

    @property
    def area(self) -> int:
        return len(self.pixels)

    @property
    def bbox(self) -> tuple[int, int, int, int]:
        return self.min_x, self.min_y, self.max_x + 1, self.max_y + 1

    @property
    def center(self) -> tuple[float, float]:
        return (self.min_x + self.max_x) / 2, (self.min_y + self.max_y) / 2


def connected_components(image: Image.Image) -> list[Component]:
    alpha = image.getchannel("A")
    width, height = image.size
    px = alpha.load()
    seen: set[tuple[int, int]] = set()
    components: list[Component] = []

    for y in range(height):
        for x in range(width):
            if not px[x, y] or (x, y) in seen:
                continue
            component = Component()
            stack = [(x, y)]
            seen.add((x, y))
            while stack:
                current_x, current_y = stack.pop()
                component.add(current_x, current_y)
                for neighbour_x in range(max(0, current_x - 1), min(width, current_x + 2)):
                    for neighbour_y in range(max(0, current_y - 1), min(height, current_y + 2)):
                        point = (neighbour_x, neighbour_y)
                        if px[neighbour_x, neighbour_y] and point not in seen:
                            seen.add(point)
                            stack.append(point)
            components.append(component)
    return components


def distance_to_bbox(component: Component, subject: Component) -> float:
    x, y = component.center
    left, top, right, bottom = subject.bbox
    dx = max(left - x, 0, x - right)
    dy = max(top - y, 0, y - bottom)
    return dx * dx + dy * dy


def extract_grouped_atlas(
    source_path: Path,
    output_dir: Path,
    prefix: str,
    subject_count: int,
    columns: int,
    major_area: int,
    canvas_size: int,
    inner_size: int,
) -> None:
    source = Image.open(source_path).convert("RGBA")
    components = connected_components(source)
    subjects = [component for component in components if component.area >= major_area]
    if len(subjects) != subject_count:
        raise RuntimeError(
            f"Expected {subject_count} subjects in {source_path}, found {len(subjects)}"
        )

    rows = subject_count // columns
    row_height = source.height / rows
    subjects.sort(
        key=lambda component: (
            min(rows - 1, int(component.center[1] / row_height)),
            component.center[0],
        )
    )
    groups: dict[int, list[Component]] = {index: [subject] for index, subject in enumerate(subjects)}
    for component in components:
        if component in subjects:
            continue
        nearest = min(
            range(len(subjects)),
            key=lambda index: distance_to_bbox(component, subjects[index]),
        )
        groups[nearest].append(component)

    output_dir.mkdir(parents=True, exist_ok=True)
    for index, group in groups.items():
        min_x = min(component.min_x for component in group)
        min_y = min(component.min_y for component in group)
        max_x = max(component.max_x for component in group) + 1
        max_y = max(component.max_y for component in group) + 1

        mask = Image.new("L", source.size, 0)
        mask_px = mask.load()
        for component in group:
            for x, y in component.pixels:
                mask_px[x, y] = 255

        isolated = Image.new("RGBA", source.size, (0, 0, 0, 0))
        isolated.paste(source, (0, 0), mask)
        isolated = isolated.crop((min_x, min_y, max_x, max_y))

        scale = min(inner_size / isolated.width, inner_size / isolated.height)
        target_size = (
            max(1, round(isolated.width * scale)),
            max(1, round(isolated.height * scale)),
        )
        isolated = isolated.resize(target_size, Image.Resampling.NEAREST)

        canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
        offset = (
            (canvas_size - isolated.width) // 2,
            (canvas_size - isolated.height) // 2,
        )
        canvas.alpha_composite(isolated, offset)
        canvas.save(output_dir / f"{prefix}-{index + 1}.png", optimize=True)


def main() -> None:
    extract_grouped_atlas(
        ROOT / "groove-bound/assets/generated/enemy-variants-atlas.png",
        ROOT / "landing-page/assets/sprites/enemies",
        "backbeat",
        subject_count=8,
        columns=4,
        major_area=10_000,
        canvas_size=512,
        inner_size=432,
    )
    extract_grouped_atlas(
        ROOT / "groove-bound/assets/generated/campaign/stage2-enemies-atlas.png",
        ROOT / "landing-page/assets/sprites/enemies",
        "orbit",
        subject_count=8,
        columns=4,
        major_area=40_000,
        canvas_size=512,
        inner_size=432,
    )
    extract_grouped_atlas(
        ROOT / "groove-bound/assets/generated/campaign/xp-gems-atlas.png",
        ROOT / "landing-page/assets/sprites/gems",
        "gem",
        subject_count=4,
        columns=2,
        major_area=20_000,
        canvas_size=627,
        inner_size=540,
    )


if __name__ == "__main__":
    main()
