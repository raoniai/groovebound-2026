#!/usr/bin/env python3
"""Build individual transparent enemy state strips and a QA manifest."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parent
GAME = ROOT.parents[3]
OLD = GAME / "assets/generated/source-candidates/2026-08-14-enemy-animation"
RUNTIME = GAME / "assets/generated/campaign/enemies"
sys.path.insert(0, str(GAME / "scripts"))
from extract_world_tour_runtime_sprites import (  # noqa: E402
    alpha_components, component_distance, isolate_atlas_sprites)

ROSTERS = {
    "backbeat": ["monotone", "tempo_leech", "metronome_guardian", "static_baron",
                 "syncopation_skitter", "feedback_phantom", "bass_brute", "noise_turret"],
    "orbit": ["vinyl_drone", "trumpet_ray", "drum_wheel", "theremin_jelly",
              "amp_hound", "keyboard_centipede", "turntable_sentinel", "grand_orchestrator"],
    "funk": ["pocket_gremlin", "slapback_hound", "groove_guard", "talkbox_oracle",
             "boogie_tank", "funkadelic_wasp", "mothership_of_funk", "pocket_phantom"],
    "soul": ["choir_automaton", "string_sentinel", "organ_walker", "harmony_linker",
             "gospel_moth", "velvet_knight", "organ_colossus", "velvet_titan"],
    "disco": ["prism_roller", "mirror_drone", "laser_fan", "reflection_twin",
              "platform_pouncer", "glitter_guard", "laser_conductor", "prism_monarch"],
    "jazz": ["syncopated_imp", "blue_note_bat", "walking_bass_bot", "scat_cannon",
             "bebop_behemoth", "brushfire_skitter", "brass_regent", "midnight_maestro"],
}

ATTACKS = {
    "backbeat": ["static_baron", "noise_turret"],
    "orbit": ["trumpet_ray", "theremin_jelly", "keyboard_centipede",
              "turntable_sentinel", "grand_orchestrator"],
    "funk": ["talkbox_oracle", "boogie_tank", "mothership_of_funk", "pocket_phantom"],
    "soul": ["string_sentinel", "harmony_linker", "organ_colossus", "velvet_titan"],
    "disco": ["laser_fan", "laser_conductor", "prism_monarch"],
    "jazz": ["scat_cannon", "bebop_behemoth", "brass_regent", "midnight_maestro"],
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def chroma_key(image: Image.Image, key: tuple[int, int, int]) -> Image.Image:
    rgb = image.convert("RGB")
    difference = ImageChops.difference(rgb, Image.new("RGB", rgb.size, key))
    red, green, blue = difference.split()
    distance = ImageChops.lighter(red, ImageChops.lighter(green, blue))
    alpha = distance.point(lambda value: 0 if value <= 34 else
                           255 if value >= 74 else round((value-34)/40*255))
    source_red, source_green, source_blue = rgb.split()
    if key[1] > 200:
        green_cap = ImageChops.lighter(source_red, source_blue).point(
            lambda value: min(255, value + 22))
        source_green = ImageChops.darker(source_green, green_cap)
    else:
        red_cap = ImageChops.lighter(source_green, source_blue).point(
            lambda value: min(255, value + 24))
        blue_cap = ImageChops.lighter(source_green, source_red).point(
            lambda value: min(255, value + 24))
        source_red = ImageChops.darker(source_red, red_cap)
        source_blue = ImageChops.darker(source_blue, blue_cap)
    rgba = Image.merge("RGB", (source_red, source_green, source_blue)).convert("RGBA")
    rgba.putalpha(alpha)
    return rgba


def isolate_adaptive(image: Image.Image, columns: int, rows: int) -> list[Image.Image]:
    components, _ = alpha_components(image)
    expected = columns * rows
    candidates = [index for index, component in enumerate(components)
                  if component["area"] >= 1000]
    if len(candidates) < expected:
        raise RuntimeError(f"Only {len(candidates)} subject components for {expected} frames")
    ordered_y = sorted(components[index]["center"][1] for index in candidates)
    centers = [ordered_y[0] + (ordered_y[-1]-ordered_y[0])
               * row/max(1, rows-1) for row in range(rows)]
    for _ in range(20):
        groups = [[] for _ in centers]
        for index in candidates:
            y = components[index]["center"][1]
            destination = min(range(rows), key=lambda row: abs(y-centers[row]))
            groups[destination].append(index)
        updated = [sum(components[index]["center"][1] for index in group)/len(group)
                   if group else centers[row] for row, group in enumerate(groups)]
        if all(abs(updated[row]-centers[row]) < .1 for row in range(rows)): break
        centers = updated
    groups = sorted(zip(centers, groups), key=lambda pair: pair[0])
    ordered = []
    for _, group in groups:
        chosen = sorted(group, key=lambda index: components[index]["area"], reverse=True)[:columns]
        if len(chosen) != columns:
            raise RuntimeError(f"Adaptive row has {len(chosen)} frames, expected {columns}")
        ordered.extend(sorted(chosen, key=lambda index: components[index]["center"][0]))
    assignments = [[] for _ in ordered]
    for component_index, component in enumerate(components):
        destination = min(range(expected), key=lambda index:
                          component_distance(component, components[ordered[index]]))
        assignments[destination].append(component_index)
    pixels = image.load()
    outputs = []
    for indices in assignments:
        bounds = [components[index]["bounds"] for index in indices]
        left, top = min(b[0] for b in bounds), min(b[1] for b in bounds)
        right, bottom = max(b[2] for b in bounds), max(b[3] for b in bounds)
        output = Image.new("RGBA", (right-left, bottom-top))
        target = output.load()
        for index in indices:
            for point in components[index]["pixels"]:
                y, x = divmod(point, image.width)
                target[x-left, y-top] = pixels[x, y]
        outputs.append(output)
    return outputs


def load_grid(path: Path, columns: int, rows: int, key: tuple[int, int, int],
              adaptive: bool = False, direct_cells: bool = False) -> list[Image.Image]:
    image = Image.open(path).convert("RGB")
    image = chroma_key(image, key)
    if adaptive:
        return isolate_adaptive(image, columns, rows)
    if direct_cells:
        cells = [image.crop((round(column * image.width / columns),
                             round(row * image.height / rows),
                             round((column + 1) * image.width / columns),
                             round((row + 1) * image.height / rows)))
                 for row in range(rows) for column in range(columns)]
        for cell in cells:
            components, _ = alpha_components(cell)
            pixels = cell.load()
            for component in components:
                if component["bounds"][1] == 0 and component["area"] < 3000:
                    for point in component["pixels"]:
                        y, x = divmod(point, cell.width)
                        pixels[x, y] = (0, 0, 0, 0)
        return cells
    isolated, _ = isolate_atlas_sprites(image, columns, rows)
    return [sprite for sprite, _ in isolated]


def normalize(frames: list[Image.Image], gutter: int = 8) -> list[Image.Image]:
    boxes = [frame.getchannel("A").getbbox() for frame in frames]
    cropped = [frame.crop(box) if box else Image.new("RGBA", (1, 1))
               for frame, box in zip(frames, boxes)]
    maximum_w = max(frame.width for frame in cropped)
    maximum_h = max(frame.height for frame in cropped)
    scale = min(1, (256-gutter*2)/maximum_w, (256-gutter*2)/maximum_h)
    result = []
    for frame in cropped:
        if scale < 1:
            frame = frame.resize((max(1, round(frame.width*scale)),
                                  max(1, round(frame.height*scale))), Image.Resampling.NEAREST)
        canvas = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        canvas.alpha_composite(frame, ((256-frame.width)//2, 256-gutter-frame.height))
        result.append(canvas)
    return result


def save_state(enemy_id: str, state: str, frames: list[Image.Image], manifest: dict) -> None:
    frames = normalize(frames)
    source_dir = ROOT / "frames" / enemy_id / state
    runtime_dir = RUNTIME / enemy_id
    source_dir.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)
    records = []
    for index, frame in enumerate(frames, 1):
        path = source_dir / f"frame-{index:02d}.png"
        frame.save(path, compress_level=3)
        bbox = frame.getchannel("A").getbbox()
        records.append({"path": path.relative_to(ROOT).as_posix(), "sha256": sha(path),
                        "alpha_bounds": list(bbox) if bbox else None})
    strip = Image.new("RGBA", (256*len(frames), 256), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame, (index*256, 0))
    strip_path = runtime_dir / f"{state}.png"
    strip.save(strip_path, compress_level=3)
    manifest[enemy_id][state] = {"frames": records, "frame_count": len(frames),
                                 "runtime_strip": strip_path.relative_to(GAME).as_posix(),
                                 "runtime_sha256": sha(strip_path),
                                 "dimensions": list(strip.size)}


def old_walk(roster: str, enemy_id: str) -> list[Image.Image]:
    folder = OLD / roster / "frames" / enemy_id
    return [Image.open(path).convert("RGBA") for path in sorted(folder.glob("frame-*.png"))]


def main() -> None:
    ids = [enemy for roster in ROSTERS.values() for enemy in roster] + ["breakbeat_bruiser"]
    manifest = {enemy_id: {} for enemy_id in ids}

    for roster, roster_ids in ROSTERS.items():
        key = (255, 0, 255) if roster == "backbeat" else (0, 255, 0)
        hit_count = 4 if roster == "jazz" else 3
        hit_columns = hit_count
        hit_cells = load_grid(ROOT/roster/f"{roster}-hit-atlas-chroma-source.png",
                              hit_columns, 8, key,
                              adaptive=roster in {"backbeat", "orbit", "funk"},
                              direct_cells=roster in {"soul", "disco"})
        death_cells = load_grid(ROOT/roster/f"{roster}-death-atlas-chroma-source.png", 4, 8, key)
        attacks = ATTACKS[roster]
        attack_cells = load_grid(ROOT/roster/f"{roster}-attack-atlas-chroma-source.png", 4, len(attacks), key)
        for index, enemy_id in enumerate(roster_ids):
            save_state(enemy_id, "walk", old_walk(roster, enemy_id), manifest)
            save_state(enemy_id, "hit", hit_cells[index*hit_count:(index+1)*hit_count], manifest)
            save_state(enemy_id, "death", death_cells[index*4:(index+1)*4], manifest)
        for index, enemy_id in enumerate(attacks):
            save_state(enemy_id, "attack", attack_cells[index*4:(index+1)*4], manifest)

    breakbeat = load_grid(ROOT/"breakbeat_bruiser"/"breakbeat_bruiser-complete-state-sheet-chroma-source.png",
                          4, 4, (0, 255, 0))
    for row, state in enumerate(("walk", "attack", "hit", "death")):
        save_state("breakbeat_bruiser", state, breakbeat[row*4:(row+1)*4], manifest)

    payload = {"generated": "2026-08-15", "status": "runtime_assets_prepared",
               "cell": [256, 256], "enemy_count": len(manifest),
               "attack_enemy_count": sum(1 for states in manifest.values() if "attack" in states),
               "enemies": manifest}
    (ROOT/"state-manifest.json").write_text(json.dumps(payload, indent=2)+"\n")
    review_dir = ROOT / "review"
    review_dir.mkdir(exist_ok=True)
    for roster, roster_ids in ROSTERS.items():
        display_ids = roster_ids + (["breakbeat_bruiser"] if roster == "orbit" else [])
        sheet = Image.new("RGBA", (1280, len(display_ids)*150), (12, 14, 30, 255))
        draw = ImageDraw.Draw(sheet)
        for row, enemy_id in enumerate(display_ids):
            draw.text((8, row*150+4), enemy_id, fill=(255, 224, 128, 255))
            for column, state in enumerate(("walk", "attack", "hit", "death")):
                path = RUNTIME / enemy_id / f"{state}.png"
                draw.text((column*320+8, row*150+22), state, fill=(210, 214, 236, 255))
                if path.exists():
                    strip = Image.open(path).convert("RGBA")
                    strip.thumbnail((312, 116), Image.Resampling.NEAREST)
                    sheet.alpha_composite(strip, (column*320+(320-strip.width)//2, row*150+34))
        sheet.save(review_dir/f"{roster}-all-states.png", compress_level=3)


if __name__ == "__main__":
    main()
