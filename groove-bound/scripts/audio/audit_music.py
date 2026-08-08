#!/usr/bin/env python3
"""Recheck every promoted runtime cue without rebuilding source audio."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from build_loop import validate_loop


CUES = [
    ("01", "01_title.ogg", 112, 32),
    ("02", "02_prologue_city.ogg", 92, 32),
    ("03", "03_prologue_break.ogg", 100, 32),
    ("04", "04_prologue_resolve.ogg", 116, 32),
    ("05", "05_character_select.ogg", 120, 32),
    ("06", "06_joe_intro.ogg", 98, 32),
    ("07", "07_lyra_intro.ogg", 142, 32),
    ("08", "08_stage1_opening.ogg", 124, 32),
    ("09", "09_stage1_pressure.ogg", 138, 32),
    ("10", "10_metronome_guardian.ogg", 136, 32),
    ("11", "11_stage1_overload.ogg", 174, 32),
    ("12", "12_static_baron.ogg", 110, 32),
    ("13", "13_first_press.ogg", 88, 32),
    ("14", "14_dead_line_recovery.ogg", 90, 32),
    ("15", "15_stage2_arrival.ogg", 126, 32),
    ("16", "16_stage2_escalation.ogg", 172, 32),
    ("17", "17_turntable_sentinel.ogg", 116, 32),
    ("18", "18_stage2_overload.ogg", 176, 32),
    ("19", "19_grand_orchestrator_p1.ogg", 132, 32),
    ("20", "20_grand_orchestrator_final.ogg", 176, 32),
    ("21", "21_level_up.ogg", 120, 32),
    ("22", "22_evolution.ogg", 140, 32),
    ("23", "23_low_health.ogg", 132, 32),
    ("24", "24_pause.ogg", 92, 32),
    ("25", "25_arsenal.ogg", 114, 32),
    ("26", "26_admin.ogg", 120, 32),
    ("27", "27_stage_clear.ogg", 124, 32),
    ("27-sting", "stage_clear_sting.ogg", 124, 8),
    ("28", "28_victory_results.ogg", 118, 32),
    ("29", "29_defeat_results.ogg", 84, 32),
    ("30", "30_ending_teaser.ogg", 96, 32),
]


def digest(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def main() -> None:
    reports = []
    for cue, filename, bpm, beats in CUES:
        path = Path("assets/music") / filename
        report = validate_loop(path, beats * 60 / bpm)
        report.update({
            "cue": cue,
            "file": filename,
            "bpm": bpm,
            "beats": beats,
            "sha256": digest(path),
        })
        reports.append(report)
    print(json.dumps(reports, indent=2))


if __name__ == "__main__":
    main()
