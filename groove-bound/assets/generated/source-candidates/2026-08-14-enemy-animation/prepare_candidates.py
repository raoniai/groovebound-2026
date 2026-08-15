#!/usr/bin/env python3
"""Slice package-excluded enemy animation candidates and emit a QA manifest."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys

from PIL import Image


ROOT = Path(__file__).resolve().parent
GAME_ROOT = ROOT.parents[3]
sys.path.insert(0, str(GAME_ROOT / "scripts"))
from extract_world_tour_runtime_sprites import isolate_atlas_sprites  # noqa: E402

ROSTERS = {
    "backbeat": {
        "layout": "columns_4_rows_6_three_frames",
        "ids": [
            "monotone", "tempo_leech", "metronome_guardian", "static_baron",
            "syncopation_skitter", "feedback_phantom", "bass_brute", "noise_turret",
        ],
    },
    "orbit": {
        "layout": "columns_4_rows_6_three_frames",
        "ids": [
            "vinyl_drone", "trumpet_ray", "drum_wheel", "theremin_jelly",
            "amp_hound", "keyboard_centipede", "turntable_sentinel", "grand_orchestrator",
        ],
    },
    "funk": {
        "layout": "columns_4_rows_6_three_frames",
        "ids": [
            "pocket_gremlin", "slapback_hound", "groove_guard", "talkbox_oracle",
            "boogie_tank", "funkadelic_wasp", "mothership_of_funk", "pocket_phantom",
        ],
    },
    "soul": {
        "layout": "columns_4_rows_6_three_frames",
        "ids": [
            "choir_automaton", "string_sentinel", "organ_walker", "harmony_linker",
            "gospel_moth", "velvet_knight", "organ_colossus", "velvet_titan",
        ],
    },
    "disco": {
        "layout": "columns_4_rows_6_three_frames",
        "ids": [
            "prism_roller", "mirror_drone", "laser_fan", "reflection_twin",
            "platform_pouncer", "glitter_guard", "laser_conductor", "prism_monarch",
        ],
    },
    "jazz": {
        "layout": "columns_4_rows_8_four_frames",
        "ids": [
            "syncopated_imp", "blue_note_bat", "walking_bass_bot", "scat_cannon",
            "bebop_behemoth", "brushfire_skitter", "brass_regent", "midnight_maestro",
        ],
    },
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_metrics(image: Image.Image) -> dict:
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    width, height = image.size
    corners = [alpha.getpixel((0, 0)), alpha.getpixel((width - 1, 0)),
               alpha.getpixel((0, height - 1)), alpha.getpixel((width - 1, height - 1))]
    return {
        "alpha_bounds": list(bbox) if bbox else None,
        "transparent_corners": all(value == 0 for value in corners),
        "edge_contact": bool(
            alpha.crop((0, 0, width, 1)).getbbox()
            or alpha.crop((0, height - 1, width, height)).getbbox()
            or alpha.crop((0, 0, 1, height)).getbbox()
            or alpha.crop((width - 1, 0, width, height)).getbbox()
        ),
    }


def frame_cell(layout: str, enemy_index: int, frame_index: int) -> int:
    if layout == "columns_4_rows_6_three_frames":
        col = enemy_index % 4
        source_row = enemy_index // 4
        row = source_row * 3 + frame_index
        return row * 4 + col

    return enemy_index * 4 + frame_index


def normalize_enemy_frames(frames: list[Image.Image], gutter: int = 12) -> list[Image.Image]:
    max_width = max(frame.width for frame in frames)
    max_height = max(frame.height for frame in frames)
    scale = min(1.0, (256 - gutter * 2) / max_width, (256 - gutter * 2) / max_height)
    normalized = []
    for frame in frames:
        if scale < 1.0:
            frame = frame.resize(
                (max(1, round(frame.width * scale)), max(1, round(frame.height * scale))),
                Image.Resampling.NEAREST,
            )
        canvas = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        canvas.alpha_composite(frame, ((256 - frame.width) // 2, 256 - gutter - frame.height))
        normalized.append(canvas)
    return normalized


def main() -> None:
    manifest = {
        "status": "source_candidate_not_runtime_integrated",
        "generated": "2026-08-14",
        "frame_canvas": [256, 256],
        "rosters": {},
        "aliases": {
            "breakbeat_bruiser": {
                "uses_animation_of": "turntable_sentinel",
                "reason": "Current content definition reuses the same Orbit atlas cell.",
            }
        },
    }

    for roster, spec in ROSTERS.items():
        source_atlas_path = ROOT / roster / f"{roster}-movement-atlas-transparent.png"
        atlas = Image.open(source_atlas_path).convert("RGBA")
        expected = (1024, 2048) if roster == "jazz" else (1024, 1536)
        if roster == "jazz" and atlas.size != expected:
            atlas = atlas.resize(expected, Image.Resampling.NEAREST)
            atlas_path = ROOT / roster / "jazz-movement-atlas-normalized-transparent.png"
            atlas.save(atlas_path, optimize=True)
        else:
            atlas_path = source_atlas_path
        if atlas.size != expected:
            raise ValueError(f"{atlas_path}: expected {expected}, got {atlas.size}")

        frame_count = 4 if roster == "jazz" else 3
        rows = 8 if roster == "jazz" else 6
        isolated_cells, discarded_noise = isolate_atlas_sprites(atlas, 4, rows)
        clean_atlas = Image.new("RGBA", expected, (0, 0, 0, 0))
        roster_record = {
            "layout": spec["layout"],
            "atlas": str(atlas_path.relative_to(ROOT)),
            "atlas_sha256": digest(atlas_path),
            "frame_count": frame_count,
            "isolation": "global-alpha-components",
            "discarded_noise_pixels": discarded_noise,
            "enemies": {},
        }

        for enemy_index, enemy_id in enumerate(spec["ids"]):
            enemy_dir = ROOT / roster / "frames" / enemy_id
            enemy_dir.mkdir(parents=True, exist_ok=True)
            frames = []
            raw_frames = [
                isolated_cells[frame_cell(spec["layout"], enemy_index, frame_index)][0]
                for frame_index in range(frame_count)
            ]
            frame_images = normalize_enemy_frames(raw_frames)
            for frame_index in range(frame_count):
                frame = frame_images[frame_index]
                frame_path = enemy_dir / f"frame-{frame_index + 1:02d}.png"
                frame.save(frame_path, optimize=True)
                metrics = alpha_metrics(frame)
                metrics.update({
                    "path": str(frame_path.relative_to(ROOT)),
                    "sha256": digest(frame_path),
                    "dimensions": list(frame.size),
                })
                frames.append(metrics)
                cell_index = frame_cell(spec["layout"], enemy_index, frame_index)
                row, col = divmod(cell_index, 4)
                clean_atlas.alpha_composite(frame, (col * 256, row * 256))

            strip = Image.new("RGBA", (256 * frame_count, 256), (0, 0, 0, 0))
            for frame_index, frame in enumerate(frame_images):
                strip.alpha_composite(frame, (frame_index * 256, 0))
            strip_path = enemy_dir / "preview-strip.png"
            strip.save(strip_path, optimize=True)
            preview_path = enemy_dir / "preview.gif"
            preview_frames = frame_images + frame_images[-2:0:-1]
            gif_frames = []
            for frame in preview_frames:
                preview = Image.new("RGBA", (256, 256), (12, 14, 30, 255))
                preview.alpha_composite(frame)
                gif_frames.append(preview.convert("RGB"))
            gif_frames[0].save(
                preview_path,
                save_all=True,
                append_images=gif_frames[1:],
                duration=140,
                loop=0,
                disposal=2,
            )

            roster_record["enemies"][enemy_id] = {
                "frames": frames,
                "preview_strip": str(strip_path.relative_to(ROOT)),
                "preview_strip_sha256": digest(strip_path),
                "preview_gif": str(preview_path.relative_to(ROOT)),
                "preview_gif_sha256": digest(preview_path),
            }

        clean_atlas_path = ROOT / roster / f"{roster}-movement-atlas-clean.png"
        clean_atlas.save(clean_atlas_path, optimize=True)
        roster_record["clean_atlas"] = str(clean_atlas_path.relative_to(ROOT))
        roster_record["clean_atlas_sha256"] = digest(clean_atlas_path)
        manifest["rosters"][roster] = roster_record

    manifest_path = ROOT / "candidate-manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
