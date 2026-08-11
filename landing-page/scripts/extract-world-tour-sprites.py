#!/usr/bin/env python3
"""Extract isolated, tightly bounded website sprites from World Tour atlases.

The runtime atlases remain untouched. Each website derivative is cropped to its
authored grid cell and then trimmed to the exact non-transparent alpha bounds.
Disconnected fragments entering through a shared cell edge are removed before
the trim. Opaque floor tiles keep their full cell because every edge is artwork.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOT = ROOT / "groove-bound/assets/generated/campaign"
OUTPUT_ROOT = ROOT / "landing-page/assets/world-tour/sprites"


def numbered(prefix: str, count: int) -> tuple[str, ...]:
    return tuple(f"{prefix}-{index:02d}" for index in range(1, count + 1))


@dataclass(frozen=True)
class AtlasSpec:
    source: str
    output: str
    columns: int
    rows: int
    names: tuple[str, ...]


SPECS = (
    AtlasSpec("funk-enemies-atlas.png", "enemies/funk", 4, 2, (
        "pocket-gremlin", "slapback-hound", "groove-guard", "talkbox-oracle",
        "boogie-tank", "funkadelic-wasp", "mothership-of-funk", "pocket-phantom",
    )),
    AtlasSpec("soul-enemies-atlas.png", "enemies/soul", 4, 2, (
        "choir-automaton", "string-sentinel", "organ-walker", "harmony-linker",
        "gospel-moth", "velvet-knight", "organ-colossus", "velvet-titan",
    )),
    AtlasSpec("disco-enemies-atlas.png", "enemies/disco", 4, 2, (
        "prism-roller", "mirror-drone", "laser-fan", "reflection-twin",
        "platform-pouncer", "glitter-guard", "laser-conductor", "prism-monarch",
    )),
    AtlasSpec("funk-environment-atlas.png", "environments/funk", 4, 2, (
        "boombox-barricade", "record-kiosk", "amp-wall", "turntable-console",
        "disco-palm", "talkbox-streetlight", "vinyl-stack", "hologram-dancer",
    )),
    AtlasSpec("soul-environment-atlas.png", "environments/soul", 4, 2, numbered("prop", 8)),
    AtlasSpec("disco-environment-atlas.png", "environments/disco", 4, 2, numbered("prop", 8)),
    AtlasSpec("funk-floor-atlas.png", "floors/funk", 2, 2, numbered("surface", 4)),
    AtlasSpec("soul-floor-atlas.png", "floors/soul", 2, 2, numbered("surface", 4)),
    AtlasSpec("disco-floor-atlas.png", "floors/disco", 2, 2, numbered("surface", 4)),
    AtlasSpec("world-mechanics-atlas.png", "mechanics", 5, 2,
              numbered("funk-pocket", 5) + numbered("disco-spotlight", 5)),
    AtlasSpec("world-tour-ui-atlas.png", "ui/world-tour", 5, 2, (
        "campaign", "funk", "soul", "locked-world", "portal",
        "grade-d", "grade-c", "grade-b", "grade-a", "grade-s",
    )),
    AtlasSpec("world-interface-atlas.png", "ui/interface", 5, 2, (
        "global-tour", "funk", "soul", "disco", "perk-database",
        "remix", "encore-gate", "world-route", "encore-coin", "mastery",
    )),
    AtlasSpec("menu-button-icons-atlas.png", "ui/menu", 5, 2, (
        "continue", "new-game", "world-tour", "settings", "quit",
        "equalizer-divider", "reset-campaign", "reset-warning", "reset-confirm", "reserved",
    )),
    AtlasSpec("../evolved-weapon-icons-atlas-2.png", "evolutions", 4, 2, (
        "prismatic-triangle", "velvet-impaler", "carnival-superorbit", "resonance-rupture",
        "stadium-keytar", "cathedral-overdrive", "infinite-mixtape", "aurora-harp",
    )),
    AtlasSpec("meta-perks-atlas.png", "perks", 5, 4, (
        "open-ears", "pocket-drive", "breakstep", "warm-current", "velvet-guard",
        "mirrorball-tips", "spotlight-spin", "four-count", "floor-control", "live-wire",
        "signal-boost", "precision-loop", "hard-reset", "orbital-balance", "encore-spark",
        "deep-reserve", "afterglow", "neon-dividend", "first-drop", "reserved-perk",
    )),
    AtlasSpec("musical-chest-atlas.png", "chests/musical", 4, 2, numbered("frame", 8)),
    AtlasSpec("chest-luck-reveal-atlas.png", "chests/luck", 5, 2,
              numbered("luck", 5) + numbered("reward-backplate", 5)),
    AtlasSpec("completion-ui-atlas.png", "chests/completion", 4, 2, (
        "backbeat-complete", "orbit-complete", "campaign-victory", "funk-mastery",
        "encore-chest", "resonance", "enemy", "boss",
    )),
    AtlasSpec("funk-pocket-pad-atlas.png", "mechanics/funk-pocket", 5, 1, numbered("pad", 5)),
)

GREEN_KEY_SOURCES = {
    "evolved-weapon-icons-atlas-2.png",
    "funk-pocket-pad-atlas.png",
    "menu-button-icons-atlas.png",
    "world-tour-ui-atlas.png",
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def clean_transparency(image: Image.Image, remove_green: bool) -> Image.Image:
    """Clear hidden RGB and remove residual chroma green from website copies."""
    rgba = image.convert("RGBA")
    cleaned = []
    for red, green, blue, alpha in rgba.getdata():
        if alpha == 0:
            cleaned.append((0, 0, 0, 0))
            continue
        if remove_green:
            dominance = green - max(red, blue)
            key = max(0.0, min(1.0, (dominance - 18) / 92)) if green > 110 else 0.0
            if key > 0:
                alpha = round(alpha * (1 - key))
                green = min(green, max(red, blue) + 18)
        cleaned.append((red, green, blue, alpha) if alpha else (0, 0, 0, 0))
    rgba.putdata(cleaned)
    return rgba


def alpha_components(rgba: Image.Image) -> tuple[list[dict[str, object]], int]:
    """Return connected alpha components and discard isolated pixel noise."""
    width, height = rgba.size
    alpha = rgba.getchannel("A")
    pixels = alpha.load()
    seen = bytearray(width * height)
    components: list[dict[str, object]] = []
    discarded_noise = 0

    for y in range(height):
        for x in range(width):
            start = y * width + x
            if seen[start] or pixels[x, y] == 0:
                continue
            seen[start] = 1
            queue = [start]
            component: list[int] = []
            minimum_x = maximum_x = x
            minimum_y = maximum_y = y
            total_x = total_y = 0
            for point in queue:
                point_y, point_x = divmod(point, width)
                component.append(point)
                minimum_x = min(minimum_x, point_x)
                maximum_x = max(maximum_x, point_x)
                minimum_y = min(minimum_y, point_y)
                maximum_y = max(maximum_y, point_y)
                total_x += point_x
                total_y += point_y
                for neighbor_y in range(max(0, point_y - 1), min(height, point_y + 2)):
                    for neighbor_x in range(max(0, point_x - 1), min(width, point_x + 2)):
                        neighbor = neighbor_y * width + neighbor_x
                        if not seen[neighbor] and pixels[neighbor_x, neighbor_y] > 0:
                            seen[neighbor] = 1
                            queue.append(neighbor)
            if len(component) < 4:
                discarded_noise += len(component)
                continue
            components.append({
                "pixels": component,
                "area": len(component),
                "bounds": [minimum_x, minimum_y, maximum_x + 1, maximum_y + 1],
                "center": [total_x / len(component), total_y / len(component)],
            })
    return components, discarded_noise


def component_distance(component: dict[str, object], primary: dict[str, object]) -> tuple[float, float]:
    """Measure a loose component against a primary sprite's global bounds."""
    center_x, center_y = component["center"]
    left, top, right, bottom = primary["bounds"]
    delta_x = max(left - center_x, 0, center_x - right)
    delta_y = max(top - center_y, 0, center_y - bottom)
    primary_x, primary_y = primary["center"]
    return delta_x * delta_x + delta_y * delta_y, (center_x - primary_x) ** 2 + (center_y - primary_y) ** 2


def isolate_atlas_sprites(
    rgba: Image.Image,
    columns: int,
    rows: int,
) -> tuple[list[tuple[Image.Image, dict[str, object]]], int]:
    """Assign global alpha components to their nearest authored sprite.

    This extracts the complete subject even when generated artwork crosses its
    nominal grid line. It also prevents a neighboring subject's connected body
    or detached particles from being copied into the wrong output.
    """
    width, height = rgba.size
    cell_width = width // columns
    cell_height = height // rows
    components, discarded_noise = alpha_components(rgba)
    if len(components) < columns * rows:
        raise RuntimeError(f"Only {len(components)} components for {columns * rows} atlas cells")

    primaries: list[int] = []
    for row in range(rows):
        for column in range(columns):
            candidates = [
                index for index, component in enumerate(components)
                if column * cell_width <= component["center"][0] < (column + 1) * cell_width
                and row * cell_height <= component["center"][1] < (row + 1) * cell_height
            ]
            if not candidates:
                raise RuntimeError(f"No primary alpha component for cell {column + 1},{row + 1}")
            primaries.append(max(candidates, key=lambda index: components[index]["area"]))
    if len(set(primaries)) != len(primaries):
        raise RuntimeError("An alpha component was selected as the primary for multiple cells")

    assignments: list[list[int]] = [[] for _ in primaries]
    for component_index, component in enumerate(components):
        if component_index in primaries:
            destination = primaries.index(component_index)
        else:
            destination = min(
                range(len(primaries)),
                key=lambda index: component_distance(component, components[primaries[index]]),
            )
        assignments[destination].append(component_index)

    source_pixels = rgba.load()
    outputs: list[tuple[Image.Image, dict[str, object]]] = []
    for cell_index, component_indices in enumerate(assignments):
        bounds = [components[index]["bounds"] for index in component_indices]
        left = min(bound[0] for bound in bounds)
        top = min(bound[1] for bound in bounds)
        right = max(bound[2] for bound in bounds)
        bottom = max(bound[3] for bound in bounds)
        output = Image.new("RGBA", (right - left, bottom - top))
        output_pixels = output.load()
        for component_index in component_indices:
            for point in components[component_index]["pixels"]:
                point_y, point_x = divmod(point, width)
                output_pixels[point_x - left, point_y - top] = source_pixels[point_x, point_y]
        row, column = divmod(cell_index, columns)
        cell_bounds = [
            column * cell_width,
            row * cell_height,
            (column + 1) * cell_width,
            (row + 1) * cell_height,
        ]
        extensions = []
        if left < cell_bounds[0]:
            extensions.append("left")
        if top < cell_bounds[1]:
            extensions.append("top")
        if right > cell_bounds[2]:
            extensions.append("right")
        if bottom > cell_bounds[3]:
            extensions.append("bottom")
        outputs.append((output, {
            "source_bounds": [left, top, right, bottom],
            "authored_cell_bounds": cell_bounds,
            "primary_component_id": primaries[cell_index],
            "source_component_ids": component_indices,
            "assigned_components": len(component_indices),
            "extends_beyond_cell": extensions,
        }))
    return outputs, discarded_noise


def tight_crop(
    cell: Image.Image,
    source: Path,
    index: int,
    remove_green: bool = False,
) -> tuple[Image.Image, tuple[int, int, int, int]]:
    rgba = clean_transparency(cell, remove_green)
    bounds = rgba.getchannel("A").getbbox()
    if bounds is None:
        raise RuntimeError(f"Empty alpha cell {index} in {source}")
    cropped = rgba.crop(bounds)
    if cropped.getchannel("A").getbbox() != (0, 0, cropped.width, cropped.height):
        raise RuntimeError(f"Transparent border remained in cell {index} of {source}")
    return cropped, bounds


def extract_atlas(spec: AtlasSpec) -> list[dict[str, object]]:
    source_path = (SOURCE_ROOT / spec.source).resolve()
    source = Image.open(source_path)
    expected = spec.columns * spec.rows
    if len(spec.names) != expected:
        raise RuntimeError(f"{spec.source}: expected {expected} names, got {len(spec.names)}")
    if source.width % spec.columns or source.height % spec.rows:
        raise RuntimeError(f"{spec.source}: dimensions do not divide by {spec.columns}x{spec.rows}")

    cell_width = source.width // spec.columns
    cell_height = source.height // spec.rows
    output_dir = OUTPUT_ROOT / spec.output
    output_dir.mkdir(parents=True, exist_ok=True)
    records: list[dict[str, object]] = []
    source_rgba = clean_transparency(source, Path(spec.source).name in GREEN_KEY_SOURCES)
    opaque_grid = source_rgba.getchannel("A").getextrema() == (255, 255)
    if opaque_grid:
        isolated = []
        discarded_noise = 0
        for zero_index in range(expected):
            row, column = divmod(zero_index, spec.columns)
            cell_bounds = [
                column * cell_width,
                row * cell_height,
                (column + 1) * cell_width,
                (row + 1) * cell_height,
            ]
            isolated.append((source_rgba.crop(cell_bounds), {
                "source_bounds": cell_bounds,
                "authored_cell_bounds": cell_bounds,
                "primary_component_id": None,
                "source_component_ids": None,
                "assigned_components": None,
                "extends_beyond_cell": [],
            }))
    else:
        isolated, discarded_noise = isolate_atlas_sprites(source_rgba, spec.columns, spec.rows)
    if len(isolated) != expected:
        raise RuntimeError(f"{spec.source}: isolated {len(isolated)} sprites, expected {expected}")

    for zero_index, (name, isolated_sprite) in enumerate(zip(spec.names, isolated)):
        cropped, isolation = isolated_sprite
        bounds = cropped.getchannel("A").getbbox()
        if bounds != (0, 0, cropped.width, cropped.height):
            raise RuntimeError(f"Transparent border remained in cell {zero_index + 1} of {source_path}")
        output_path = output_dir / f"{name}.png"
        cropped.save(output_path, optimize=True)
        records.append({
            "source": str(source_path.relative_to(ROOT)),
            "source_sha256": digest(source_path),
            "grid": [spec.columns, spec.rows],
            "cell": zero_index + 1,
            "cell_size": [cell_width, cell_height],
            "isolation": "opaque-grid-cell" if opaque_grid else "global-alpha-components",
            **isolation,
            "discarded_noise_pixels": discarded_noise,
            "alpha_bounds": [0, 0, cropped.width, cropped.height],
            "output": str(output_path.relative_to(ROOT)),
            "output_size": [cropped.width, cropped.height],
            "output_sha256": digest(output_path),
        })
    return records


def extract_single(source_name: str, output_name: str) -> dict[str, object]:
    source_path = SOURCE_ROOT / source_name
    source = Image.open(source_path)
    cropped, bounds = tight_crop(source, source_path, 1)
    output_path = OUTPUT_ROOT / output_name
    output_path.parent.mkdir(parents=True, exist_ok=True)
    cropped.save(output_path, optimize=True)
    return {
        "source": str(source_path.relative_to(ROOT)),
        "source_sha256": digest(source_path),
        "grid": [1, 1],
        "cell": 1,
        "cell_size": [source.width, source.height],
        "isolation": "single-image-alpha-trim",
        "source_bounds": list(bounds),
        "authored_cell_bounds": [0, 0, source.width, source.height],
        "primary_component_id": None,
        "source_component_ids": None,
        "assigned_components": None,
        "extends_beyond_cell": [],
        "discarded_noise_pixels": 0,
        "alpha_bounds": [0, 0, cropped.width, cropped.height],
        "output": str(output_path.relative_to(ROOT)),
        "output_size": [cropped.width, cropped.height],
        "output_sha256": digest(output_path),
    }


def main() -> None:
    records: list[dict[str, object]] = []
    for spec in SPECS:
        records.extend(extract_atlas(spec))
    records.append(extract_single("stage-clear-chest.png", "chests/encore-gate.png"))
    manifest = {
        "policy": (
            "Assign atlas-wide connected alpha components to their nearest authored "
            "sprite, recover complete subjects across nominal cell lines, discard isolated "
            "pixel noise, and trim to visible alpha bounds without resizing. Opaque floor "
            "textures retain their exact authored cells."
        ),
        "source_root": str(SOURCE_ROOT.relative_to(ROOT)),
        "output_root": str(OUTPUT_ROOT.relative_to(ROOT)),
        "count": len(records),
        "records": records,
    }
    manifest_path = OUTPUT_ROOT / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    component_outputs = sum(record["isolation"] == "global-alpha-components" for record in records)
    extended_outputs = sum(bool(record["extends_beyond_cell"]) for record in records)
    print(f"Extracted {len(records)} isolated World Tour sprites.")
    print(f"Segmented {component_outputs} sprites globally; recovered {extended_outputs} across cell edges.")
    print(f"Manifest: {manifest_path}")


if __name__ == "__main__":
    main()
