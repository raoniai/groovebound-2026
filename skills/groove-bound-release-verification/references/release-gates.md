# Release gates

| Layer | Required evidence |
|---|---|
| Source | Scope-resolved diff and no accidental files |
| Unit | Full LuaJIT suite result |
| Static | Luacheck and diff check |
| Package | Rebuilt `.love`, valid ZIP, required assets present, exclusions honored |
| Boot | Packaged build reaches boot-complete path |
| Manual | Changed criteria and representative campaign flow played |
| Version control | Commit SHA and branch |
| Remote | Exact pushed branch and remote SHA |
| Main | Independent `origin/main` verification |
| Release | Release record and downloadable artifact |
| Public | Download and launch from the public route |

Keep artifact hashes and mutable counts in the handover or generated manifest, not in SKILL.md.
