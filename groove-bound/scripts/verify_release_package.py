#!/usr/bin/env python3
"""Verify release-only invariants in a Groove Bound .love archive."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import zipfile
from pathlib import Path


GAME_ROOT = Path(__file__).resolve().parents[1]
RUNTIME_ASSET_LITERAL = re.compile(
    r'''["'](assets/[^"']+\.(?:jpe?g|ogg|ogv|png|ttf|wav))["']''',
    re.IGNORECASE,
)
PLAYER_ATTACK_IDS = (
    "kazoo_pistol", "bass_drop", "cymbal_slicer", "feedback_loop",
    "drum_circle", "trumpet_burst", "vinyl_scratch", "synth_wave",
    "triangle_tracer", "cello_lance", "maraca_orbit", "tuning_fork",
    "keytar_chord", "bell_tower", "tape_repeater", "laser_harp",
    "brass_barrage", "improvised_solo", "subwoofer_supernova",
    "orbital_ovation", "thunderhead_ensemble", "golden_fortissimo",
    "gravity_groove", "neon_crescendo", "prismatic_triangle",
    "velvet_impaler", "carnival_superorbit", "resonance_rupture",
    "stadium_keytar", "cathedral_overdrive", "infinite_mixtape",
    "aurora_harp",
)


def runtime_asset_references() -> list[str]:
    sources = [GAME_ROOT / "main.lua", GAME_ROOT / "conf.lua"]
    sources.extend(sorted((GAME_ROOT / "src").rglob("*.lua")))
    references = set()
    for source in sources:
        if not source.is_file():
            continue
        references.update(
            match.group(1)
            for match in RUNTIME_ASSET_LITERAL.finditer(
                source.read_text(encoding="utf-8")
            )
        )
    return sorted(references)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("artifact", type=Path)
    args = parser.parse_args()
    artifact = args.artifact.resolve()

    with zipfile.ZipFile(artifact) as archive:
        bad = archive.testzip()
        names = archive.namelist()
        marker = archive.read("release-build.txt").decode("utf-8") \
            if "release-build.txt" in names else ""

    forbidden = [
        name for name in names
        if name.startswith(("tests/", "docs/", "design-system/", "scripts/"))
        or name.endswith("-source.png")
        or "/source-candidates/" in f"/{name}"
        or name.endswith(".mp4")
    ]
    referenced_assets = runtime_asset_references()
    missing_referenced_assets = [
        name for name in referenced_assets if name not in names
    ]
    missing_player_attacks = [
        f"assets/generated/projectiles/{attack_id}.png"
        for attack_id in PLAYER_ATTACK_IDS
        if f"assets/generated/projectiles/{attack_id}.png" not in names
    ]
    retired_projectile_atlases = [
        name for name in (
            "assets/generated/campaign/projectile-atlas.png",
            "assets/generated/campaign/attack-visuals-atlas.png",
        ) if name in names
    ]
    marker_fields = dict(
        line.split("=", 1) for line in marker.splitlines() if "=" in line
    )
    errors = []
    if bad:
        errors.append(f"bad archive entry: {bad}")
    if forbidden:
        errors.append("forbidden release entries present")
    if missing_referenced_assets:
        errors.append("runtime-referenced assets missing from release")
    if missing_player_attacks:
        errors.append("separate player attack animations missing from release")
    if retired_projectile_atlases:
        errors.append("retired combined projectile atlas present in release")
    if marker_fields.get("profile") != "release":
        errors.append("release marker is missing")
    if marker_fields.get("dirty") != "false":
        errors.append("release payload was built from a dirty game tree")

    print(json.dumps({
        "artifact": str(artifact),
        "bytes": artifact.stat().st_size,
        "sha256": sha256(artifact),
        "entries": len(names),
        "marker": marker_fields,
        "forbidden_entries": forbidden,
        "runtime_asset_references": len(referenced_assets),
        "missing_referenced_assets": missing_referenced_assets,
        "missing_player_attacks": missing_player_attacks,
        "retired_projectile_atlases": retired_projectile_atlases,
        "errors": errors,
    }, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
