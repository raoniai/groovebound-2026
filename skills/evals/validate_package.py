#!/usr/bin/env python3
"""Validate the repository-owned Groove Bound Studio skill package."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SKILLS_ROOT = ROOT / "skills"


def main() -> int:
    manifest = json.loads((SKILLS_ROOT / "package.json").read_text())
    errors: list[str] = []
    results = []
    for name in manifest["skills"]:
        folder = SKILLS_ROOT / name
        skill_file = folder / "SKILL.md"
        agent_file = folder / "agents" / "openai.yaml"
        if not skill_file.is_file() or not agent_file.is_file():
            errors.append(f"{name}: missing SKILL.md or agents/openai.yaml")
            continue
        text = skill_file.read_text()
        lines = text.splitlines()
        frontmatter = re.match(r"^---\n(.*?)\n---", text, re.DOTALL)
        if not frontmatter:
            errors.append(f"{name}: invalid frontmatter")
            continue
        name_match = re.search(r"^name:\s*(.+)$", frontmatter.group(1), re.MULTILINE)
        description_match = re.search(r"^description:\s*(.+)$", frontmatter.group(1), re.MULTILINE)
        if not name_match or name_match.group(1).strip() != name:
            errors.append(f"{name}: frontmatter name mismatch")
        if not description_match or len(description_match.group(1).strip()) < 40:
            errors.append(f"{name}: description is missing or too weak")
        if len(lines) >= 500:
            errors.append(f"{name}: SKILL.md exceeds 499 lines")
        if "TODO" in text or "placeholder" in text.lower():
            errors.append(f"{name}: placeholder text remains")
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", text):
            if "://" not in target and not (folder / target).exists():
                errors.append(f"{name}: broken local reference {target}")
        agent = agent_file.read_text()
        default_match = re.search(r'^\s*default_prompt:\s*"([^"]+)"', agent, re.MULTILINE)
        short_match = re.search(r'^\s*short_description:\s*"([^"]+)"', agent, re.MULTILINE)
        if not default_match or f"${name}" not in default_match.group(1):
            errors.append(f"{name}: default prompt does not invoke the skill")
        if not short_match or not 25 <= len(short_match.group(1)) <= 64:
            errors.append(f"{name}: short description must be 25-64 characters")
        scripts = list((folder / "scripts").glob("*.py")) if (folder / "scripts").exists() else []
        for script in scripts:
            if not script.stat().st_mode & 0o111:
                errors.append(f"{name}: script is not executable: {script.name}")
        results.append({"name": name, "skill_lines": len(lines), "scripts": len(scripts)})
    handover = ROOT / "LATEST_VERSION_HANDOVER.md"
    if not handover.is_file():
        errors.append("LATEST_VERSION_HANDOVER.md is missing")
    else:
        content = handover.read_text()
        if content.count("<!-- LIVE-SNAPSHOT:START -->") != 1 or content.count("<!-- LIVE-SNAPSHOT:END -->") != 1:
            errors.append("handover live snapshot markers are invalid")
    payload = {"package": manifest["name"], "skills": results, "errors": errors}
    print(json.dumps(payload, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
