#!/usr/bin/env python3
"""Repair World Tour runtime atlases through clean sprite isolation.

Transparent atlases are segmented across the full image before each assigned
subject is tightly cropped. Each atlas is then rebuilt at its original size and
grid with uniformly scaled, centred subjects and transparent safe gutters. The
game keeps its existing atlas loader and stable row/column mappings.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


GAME_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = GAME_ROOT / "assets/generated/campaign"
OUTPUT_ROOT = SOURCE_ROOT / "world-tour-sprites"
MANIFEST_PATH = OUTPUT_ROOT / "manifest.json"


def numbered(prefix: str, count: int) -> tuple[str, ...]:
    return tuple(f"{prefix}-{index:02d}" for index in range(1, count + 1))


@dataclass(frozen=True)
class AtlasSpec:
    source: str
    group: str
    columns: int
    rows: int
    inset: int
    names: tuple[str, ...]


SPECS = (
    AtlasSpec("funk-enemies-atlas.png", "enemies/funk", 4, 2, 2, (
        "pocket-gremlin", "slapback-hound", "groove-guard", "talkbox-oracle",
        "boogie-tank", "funkadelic-wasp", "mothership-of-funk", "pocket-phantom",
    )),
    AtlasSpec("soul-enemies-atlas.png", "enemies/soul", 4, 2, 8, (
        "choir-automaton", "string-sentinel", "organ-walker", "harmony-linker",
        "gospel-moth", "velvet-knight", "organ-colossus", "velvet-titan",
    )),
    AtlasSpec("disco-enemies-atlas.png", "enemies/disco", 4, 2, 8, (
        "prism-roller", "mirror-drone", "laser-fan", "reflection-twin",
        "platform-pouncer", "glitter-guard", "laser-conductor", "prism-monarch",
    )),
    AtlasSpec("funk-environment-atlas.png", "environments/funk", 4, 2, 2, (
        "boombox-barricade", "record-kiosk", "amp-wall", "turntable-console",
        "disco-palm", "talkbox-streetlight", "vinyl-stack", "hologram-dancer",
    )),
    AtlasSpec("soul-environment-atlas.png", "environments/soul", 4, 2, 8,
              numbered("prop", 8)),
    AtlasSpec("disco-environment-atlas.png", "environments/disco", 4, 2, 8,
              numbered("prop", 8)),
    AtlasSpec("world-mechanics-atlas.png", "mechanics", 5, 2, 4,
              numbered("funk-pocket", 5) + numbered("disco-spotlight", 5)),
    AtlasSpec("world-tour-ui-atlas.png", "ui/world-tour", 5, 2, 8, (
        "campaign", "funk", "soul", "locked-world", "portal",
        "grade-d", "grade-c", "grade-b", "grade-a", "grade-s",
    )),
    AtlasSpec("world-interface-atlas.png", "ui/interface", 5, 2, 8, (
        "global-tour", "funk", "soul", "disco", "perk-database",
        "remix", "encore-gate", "world-route", "encore-coin", "mastery",
    )),
    AtlasSpec("menu-button-icons-atlas.png", "ui/menu", 5, 2, 0, (
        "continue", "new-game", "world-tour", "settings", "quit",
        "equalizer-divider", "reset-campaign", "reset-warning", "reset-confirm", "reserved",
    )),
    AtlasSpec("../evolved-weapon-icons-atlas-2.png", "evolutions", 4, 2, 8, (
        "prismatic-triangle", "velvet-impaler", "carnival-superorbit", "resonance-rupture",
        "stadium-keytar", "cathedral-overdrive", "infinite-mixtape", "aurora-harp",
    )),
    AtlasSpec("meta-perks-atlas.png", "perks", 5, 4, 8, (
        "open-ears", "pocket-drive", "breakstep", "warm-current", "velvet-guard",
        "mirrorball-tips", "spotlight-spin", "four-count", "floor-control", "live-wire",
        "signal-boost", "precision-loop", "hard-reset", "orbital-balance", "encore-spark",
        "deep-reserve", "afterglow", "neon-dividend", "first-drop", "reserved-perk",
    )),
    AtlasSpec("musical-chest-atlas.png", "chests/musical", 4, 2, 0,
              numbered("frame", 8)),
    AtlasSpec("chest-luck-reveal-atlas.png", "chests/luck", 5, 2, 2,
              numbered("luck", 5) + numbered("reward-backplate", 5)),
    AtlasSpec("completion-ui-atlas.png", "chests/completion", 4, 2, 2, (
        "backbeat-complete", "orbit-complete", "campaign-victory", "funk-mastery",
        "encore-chest", "resonance", "enemy", "boss",
    )),
    AtlasSpec("funk-pocket-pad-atlas.png", "mechanics/funk-pocket", 5, 1, 0,
              numbered("pad", 5)),
)

GREEN_KEY_SOURCES = {
    "evolved-weapon-icons-atlas-2.png",
    "funk-pocket-pad-atlas.png",
    "menu-button-icons-atlas.png",
    "world-tour-ui-atlas.png",
}

TARGET_ATLAS_SIZES = {
    # The source was a square 4x2 sheet, producing 314x628 runtime cells.
    # Normalise it to the same square 400px cell contract as adjacent atlases.
    "musical-chest-atlas.png": (1600, 800),
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def relative(path: Path) -> str:
    return path.resolve().relative_to(GAME_ROOT).as_posix()


def clean_transparency(image: Image.Image, remove_green: bool) -> Image.Image:
    """Normalize hidden RGB and remove residual generator chroma green."""
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
    width, height = rgba.size
    pixels = rgba.getchannel("A").load()
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
            component_pixels: list[int] = []
            left = right = x
            top = bottom = y
            total_x = total_y = 0
            for point in queue:
                point_y, point_x = divmod(point, width)
                component_pixels.append(point)
                left, right = min(left, point_x), max(right, point_x)
                top, bottom = min(top, point_y), max(bottom, point_y)
                total_x += point_x
                total_y += point_y
                for neighbor_y in range(max(0, point_y - 1), min(height, point_y + 2)):
                    for neighbor_x in range(max(0, point_x - 1), min(width, point_x + 2)):
                        neighbor = neighbor_y * width + neighbor_x
                        if not seen[neighbor] and pixels[neighbor_x, neighbor_y] > 0:
                            seen[neighbor] = 1
                            queue.append(neighbor)
            if len(component_pixels) < 4:
                discarded_noise += len(component_pixels)
                continue
            components.append({
                "pixels": component_pixels,
                "area": len(component_pixels),
                "bounds": [left, top, right + 1, bottom + 1],
                "center": [total_x / len(component_pixels), total_y / len(component_pixels)],
            })
    return components, discarded_noise


def component_distance(
    component: dict[str, object], primary: dict[str, object]
) -> tuple[float, float]:
    center_x, center_y = component["center"]
    left, top, right, bottom = primary["bounds"]
    delta_x = max(left - center_x, 0, center_x - right)
    delta_y = max(top - center_y, 0, center_y - bottom)
    primary_x, primary_y = primary["center"]
    return (
        delta_x * delta_x + delta_y * delta_y,
        (center_x - primary_x) ** 2 + (center_y - primary_y) ** 2,
    )


def isolate_atlas_sprites(
    rgba: Image.Image, columns: int, rows: int
) -> tuple[list[tuple[Image.Image, dict[str, object]]], int]:
    """Assign each global alpha component to one authored grid subject."""
    width, height = rgba.size
    cell_width, cell_height = width // columns, height // rows
    components, discarded_noise = alpha_components(rgba)
    expected = columns * rows
    if len(components) < expected:
        raise RuntimeError(f"Only {len(components)} components for {expected} atlas cells")

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
        raise RuntimeError("An alpha component was selected for multiple cells")

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

    if sorted(index for values in assignments for index in values) != list(range(len(components))):
        raise RuntimeError("Component assignment is incomplete or duplicated")

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
        if left < cell_bounds[0]: extensions.append("left")
        if top < cell_bounds[1]: extensions.append("top")
        if right > cell_bounds[2]: extensions.append("right")
        if bottom > cell_bounds[3]: extensions.append("bottom")
        outputs.append((output, {
            "source_bounds": [left, top, right, bottom],
            "authored_cell_bounds": cell_bounds,
            "primary_component_id": primaries[cell_index],
            "source_component_ids": component_indices,
            "assigned_components": len(component_indices),
            "extends_beyond_cell": extensions,
        }))
    return outputs, discarded_noise


def extract_atlas(spec: AtlasSpec) -> list[dict[str, object]]:
    source_path = (SOURCE_ROOT / spec.source).resolve()
    source = Image.open(source_path)
    expected = spec.columns * spec.rows
    if len(spec.names) != expected:
        raise RuntimeError(f"{spec.source}: expected {expected} names, got {len(spec.names)}")
    if source.width % spec.columns or source.height % spec.rows:
        raise RuntimeError(f"{spec.source}: invalid {spec.columns}x{spec.rows} dimensions")

    cell_width, cell_height = source.width // spec.columns, source.height // spec.rows
    source_rgba = clean_transparency(source, source_path.name in GREEN_KEY_SOURCES)
    isolated, discarded_noise = isolate_atlas_sprites(source_rgba, spec.columns, spec.rows)
    records: list[dict[str, object]] = []
    output_dir = OUTPUT_ROOT / spec.group
    output_dir.mkdir(parents=True, exist_ok=True)

    for zero_index, (name, isolated_sprite) in enumerate(zip(spec.names, isolated)):
        sprite, isolation = isolated_sprite
        if sprite.getchannel("A").getbbox() != (0, 0, sprite.width, sprite.height):
            raise RuntimeError(f"Transparent border remained in {spec.source} cell {zero_index + 1}")
        output_path = output_dir / f"{name}.png"
        sprite.save(output_path, optimize=True)
        row, column = divmod(zero_index, spec.columns)
        cell_left, cell_top, cell_right, cell_bottom = isolation["authored_cell_bounds"]
        source_left, source_top, _, _ = isolation["source_bounds"]
        records.append({
            "group": spec.group,
            "name": name,
            "row": row + 1,
            "col": column + 1,
            "source": relative(source_path),
            "source_sha256": digest(source_path),
            "grid": [spec.columns, spec.rows],
            "cell": zero_index + 1,
            "cell_size": [cell_width, cell_height],
            "reference_size": [cell_width - spec.inset * 2, cell_height - spec.inset * 2],
            "anchor": [
                (cell_left + cell_right) / 2 - source_left,
                (cell_top + cell_bottom) / 2 - source_top,
            ],
            "isolation": "global-alpha-components",
            **isolation,
            "discarded_noise_pixels": discarded_noise,
            "alpha_bounds": [0, 0, sprite.width, sprite.height],
            "output": relative(output_path),
            "output_size": [sprite.width, sprite.height],
            "output_sha256": digest(output_path),
        })
    return records


def rebuild_atlas(spec: AtlasSpec, records: list[dict[str, object]]) -> None:
    """Recompose an atlas without cross-cell fragments or non-uniform scaling."""
    source_path = (SOURCE_ROOT / spec.source).resolve()
    source = Image.open(source_path)
    target_size = TARGET_ATLAS_SIZES.get(source_path.name, source.size)
    cell_width, cell_height = target_size[0] // spec.columns, target_size[1] // spec.rows
    repaired = Image.new("RGBA", target_size)
    safe_gutter = max(8, spec.inset)

    for record in records:
        sprite = Image.open(GAME_ROOT / record["output"]).convert("RGBA")
        available_width = cell_width - safe_gutter * 2
        available_height = cell_height - safe_gutter * 2
        scale = min(1.0, available_width / sprite.width, available_height / sprite.height)
        if scale < 1.0:
            size = (
                max(1, round(sprite.width * scale)),
                max(1, round(sprite.height * scale)),
            )
            sprite = sprite.resize(size, Image.Resampling.NEAREST)
        cell_left = (record["col"] - 1) * cell_width
        cell_top = (record["row"] - 1) * cell_height
        paste_x = cell_left + (cell_width - sprite.width) // 2
        paste_y = cell_top + (cell_height - sprite.height) // 2
        repaired.alpha_composite(sprite, (paste_x, paste_y))

    repaired.save(source_path, optimize=True)


def repair_atlas(spec: AtlasSpec) -> list[dict[str, object]]:
    """Repair once, then re-extract and recompose to make the result idempotent."""
    source_path = (SOURCE_ROOT / spec.source).resolve()
    original_dimensions = list(Image.open(source_path).size)
    first_pass = extract_atlas(spec)
    rebuild_atlas(spec, first_pass)
    records = extract_atlas(spec)
    rebuild_atlas(spec, records)
    source_hash = digest(source_path)
    final_dimensions = list(Image.open(source_path).size)
    for record in records:
        record["source_sha256"] = source_hash
        record["atlas_repair"] = {
            "original_dimensions": original_dimensions,
            "final_dimensions": final_dimensions,
            "dimensions_preserved": original_dimensions == final_dimensions,
            "grid_preserved": True,
            "uniform_scale_only": True,
            "safe_gutter": max(8, spec.inset),
        }
    return records


def validate_manifest(manifest: dict[str, object]) -> list[str]:
    errors: list[str] = []
    records = manifest.get("records", [])
    if manifest.get("count") != 147 or len(records) != 147:
        errors.append(f"expected 147 records, got {len(records)}")
    outputs = [record["output"] for record in records]
    if len(set(outputs)) != len(outputs):
        errors.append("duplicate output paths")
    by_source: dict[str, list[int]] = {}
    for record in records:
        output_path = GAME_ROOT / record["output"]
        source_path = GAME_ROOT / record["source"]
        if not output_path.is_file():
            errors.append(f"missing {record['output']}")
            continue
        if digest(output_path) != record["output_sha256"]:
            errors.append(f"output hash mismatch: {record['output']}")
        if digest(source_path) != record["source_sha256"]:
            errors.append(f"source changed: {record['source']}")
        image = Image.open(output_path).convert("RGBA")
        if image.size != tuple(record["output_size"]):
            errors.append(f"size mismatch: {record['output']}")
        if image.getchannel("A").getbbox() != (0, 0, image.width, image.height):
            errors.append(f"transparent border: {record['output']}")
        source_key = record["source"]
        by_source.setdefault(source_key, []).extend(record["source_component_ids"])
    for source_path, component_ids in by_source.items():
        if len(component_ids) != len(set(component_ids)):
            errors.append(f"component reused across sprites: {source_path}")
    atlas_records: dict[str, list[dict[str, object]]] = {}
    for record in records:
        atlas_records.setdefault(record["source"], []).append(record)
    for source_name, source_records in atlas_records.items():
        atlas = Image.open(GAME_ROOT / source_name).convert("RGBA")
        columns, rows = source_records[0]["grid"]
        cell_width, cell_height = atlas.width // columns, atlas.height // rows
        alpha = atlas.getchannel("A")
        for record in source_records:
            left = (record["col"] - 1) * cell_width
            top = (record["row"] - 1) * cell_height
            cell = alpha.crop((left, top, left + cell_width, top + cell_height))
            bounds = cell.getbbox()
            gutter = record["atlas_repair"]["safe_gutter"]
            if bounds is None:
                errors.append(f"empty atlas cell: {source_name} {record['row']},{record['col']}")
            elif (bounds[0] < gutter or bounds[1] < gutter
                  or bounds[2] > cell_width - gutter or bounds[3] > cell_height - gutter):
                errors.append(f"unsafe atlas edge: {source_name} {record['row']},{record['col']}")
    return errors


def build() -> dict[str, object]:
    records: list[dict[str, object]] = []
    for spec in SPECS:
        records.extend(repair_atlas(spec))
    manifest = {
        "schema": 1,
        "policy": (
            "Assign atlas-wide connected alpha components to one nearest authored sprite, "
            "recover complete subjects across nominal cell lines, remove isolated pixel noise, "
            "then rebuild the existing atlas grid with uniform scaling, centred subjects and "
            "safe transparent gutters. Runtime atlas loading and row-column mappings remain "
            "unchanged; the malformed musical chest canvas is normalised to square cells."
        ),
        "source_root": relative(SOURCE_ROOT),
        "output_root": relative(OUTPUT_ROOT),
        "count": len(records),
        "records": records,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="validate existing outputs only")
    args = parser.parse_args()
    if args.check:
        manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    else:
        manifest = build()
    errors = validate_manifest(manifest)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    extended = sum(bool(record["extends_beyond_cell"]) for record in manifest["records"])
    print(f"Validated {manifest['count']} isolated World Tour runtime sprites.")
    print(f"Repaired {len(SPECS)} atlases without changing loaders or cell mappings.")
    print(f"Final edge crossings: {extended}; no component reuse.")
    print(f"Manifest: {MANIFEST_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
