#!/usr/bin/env python3
"""Find a musical beat window and export a validated game-ready OGG loop."""

from __future__ import annotations

import argparse
import json
import math
import re
import subprocess
from pathlib import Path

import librosa
import numpy as np
import soundfile as sf


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, text=True, capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return result


def normalized_tempo(estimated: float, expected: float) -> float:
    candidates = [estimated * (2**offset) for offset in range(-2, 3)]
    return min(candidates, key=lambda value: abs(math.log(value / expected)))


def beat_window(source: Path, bpm: float, beats: int) -> dict[str, float]:
    audio, sample_rate = librosa.load(source, sr=22050, mono=True)
    onset = librosa.onset.onset_strength(y=audio, sr=sample_rate)
    estimated = float(np.asarray(librosa.feature.tempo(
        onset_envelope=onset, sr=sample_rate, start_bpm=bpm))[0])
    tempo = normalized_tempo(estimated, bpm)
    _, beat_frames = librosa.beat.beat_track(
        onset_envelope=onset, sr=sample_rate, bpm=tempo, units="frames")
    beat_times = librosa.frames_to_time(beat_frames, sr=sample_rate)
    target = beats * 60 / bpm

    if len(beat_times) < beats + 1:
        first = float(librosa.frames_to_time(
            int(np.argmax(onset)), sr=sample_rate))
        beat_times = np.arange(first, len(audio) / sample_rate, 60 / tempo)
    if len(beat_times) < beats + 1:
        raise RuntimeError(f"not enough detected beats for {beats}-beat loop")

    chroma = librosa.feature.chroma_stft(y=audio, sr=sample_rate)
    rms = librosa.feature.rms(y=audio)[0]
    frame_rate = sample_rate / 512

    def edge_features(time_seconds: float) -> tuple[np.ndarray, float]:
        center = int(time_seconds * frame_rate)
        radius = max(1, int(0.18 * frame_rate))
        lo = max(0, center - radius)
        hi = min(chroma.shape[1], center + radius + 1)
        return np.mean(chroma[:, lo:hi], axis=1), float(np.mean(rms[lo:hi]))

    choices: list[tuple[float, int, float]] = []
    for index in range(0, len(beat_times) - beats):
        start = float(beat_times[index])
        end = float(beat_times[index + beats])
        duration = end - start
        if start < 1 or end > len(audio) / sample_rate - 0.05:
            continue
        start_chroma, start_rms = edge_features(start)
        end_chroma, end_rms = edge_features(end)
        chroma_distance = float(np.mean(np.abs(start_chroma - end_chroma)))
        rms_distance = abs(20 * math.log10(max(start_rms, 1e-8))
                           - 20 * math.log10(max(end_rms, 1e-8))) / 20
        duration_error = abs(duration - target) / target
        intro_penalty = max(0, 5 - start) / 25
        score = duration_error * 4 + chroma_distance + rms_distance + intro_penalty
        choices.append((score, index, duration))

    if not choices:
        raise RuntimeError("no usable beat window found")
    score, index, duration = min(choices)
    correction = duration / target
    if correction < 0.80 or correction > 1.25:
        raise RuntimeError(
            f"tempo correction {correction:.3f} exceeds safe range")
    return {
        "start": float(beat_times[index]),
        "source_duration": duration,
        "target_duration": target,
        "estimated_bpm": estimated,
        "normalized_bpm": tempo,
        "tempo_correction": correction,
        "selection_score": score,
    }


def export_loop(source: Path, output: Path, window: dict[str, float]) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    target = window["target_duration"]
    fade = min(0.006, target / 1000)
    filters = (
        f"atempo={window['tempo_correction']:.9f},"
        f"afade=t=in:st=0:d={fade:.6f},"
        f"afade=t=out:st={target - fade:.9f}:d={fade:.6f},"
        "loudnorm=I=-18:LRA=7:TP=-1"
    )
    run([
        "ffmpeg", "-y", "-v", "error",
        "-ss", f"{window['start']:.9f}",
        "-t", f"{window['source_duration']:.9f}",
        "-i", str(source),
        "-vn",
        "-af", filters,
        "-ar", "48000", "-ac", "2",
        "-c:a", "vorbis", "-strict", "experimental", "-q:a", "6",
        str(output),
    ])


def validate_loop(output: Path, target: float) -> dict[str, float | int | str]:
    probe = json.loads(run([
        "ffprobe", "-v", "error", "-show_streams", "-show_format",
        "-of", "json", str(output),
    ]).stdout)
    stream = next(item for item in probe["streams"] if item["codec_type"] == "audio")
    container_duration = float(probe["format"]["duration"])
    audio, sample_rate = sf.read(output, always_2d=True)
    duration = len(audio) / sample_rate
    edge_samples = max(1, int(sample_rate * 0.05))
    first_rms = float(np.sqrt(np.mean(audio[:edge_samples] ** 2)))
    last_rms = float(np.sqrt(np.mean(audio[-edge_samples:] ** 2)))
    seam_jump = float(np.max(np.abs(audio[-1] - audio[0])))

    loudness_output = subprocess.run([
        "ffmpeg", "-hide_banner", "-nostats", "-i", str(output),
        "-af", "ebur128=peak=true", "-f", "null", "-",
    ], text=True, capture_output=True, check=True).stderr
    integrated_matches = re.findall(r"I:\s+(-?\d+(?:\.\d+)?) LUFS", loudness_output)
    peak_matches = re.findall(r"Peak:\s+(-?\d+(?:\.\d+)?) dBFS", loudness_output)
    integrated = float(integrated_matches[-1])
    true_peak = float(peak_matches[-1])

    checks = {
        "codec": stream["codec_name"] == "vorbis",
        "sample_rate": int(stream["sample_rate"]) == 48000,
        "channels": int(stream["channels"]) == 2,
        "duration": abs(duration - target) <= 0.04,
        "loudness": abs(integrated + 18) <= 1.2,
        "true_peak": true_peak <= -0.8,
        "seam_jump": seam_jump <= 0.08,
        "audible_edges": first_rms >= 0.002 and last_rms >= 0.002,
    }
    failed = [name for name, passed in checks.items() if not passed]
    result: dict[str, float | int | str] = {
        "codec": stream["codec_name"],
        "sample_rate": int(stream["sample_rate"]),
        "channels": int(stream["channels"]),
        "duration": duration,
        "container_duration": container_duration,
        "integrated_lufs": integrated,
        "true_peak_dbfs": true_peak,
        "seam_jump": seam_jump,
        "first_50ms_rms": first_rms,
        "last_50ms_rms": last_rms,
        "status": "passed" if not failed else "failed: " + ", ".join(failed),
    }
    if failed:
        raise RuntimeError(json.dumps(result, indent=2))
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--bpm", type=float, required=True)
    parser.add_argument("--beats", type=int, default=32)
    args = parser.parse_args()

    window = beat_window(args.source, args.bpm, args.beats)
    export_loop(args.source, args.output, window)
    validation = validate_loop(args.output, window["target_duration"])
    print(json.dumps({"window": window, "validation": validation}, indent=2))


if __name__ == "__main__":
    main()
