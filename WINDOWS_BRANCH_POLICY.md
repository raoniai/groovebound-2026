# Groove Bound Windows Branch Policy

## Branch roles

- `codex/world-tour-v1` is the canonical source for gameplay, content, interface,
  shared runtime assets, saves, and cross-platform fixes.
- `codex/windows-version` is the downstream Windows delivery branch. It may add
  Windows packaging, metadata, diagnostics, and target-native verification, but
  it must not become a separate gameplay implementation.

Both branches build from the same Lua/LÖVE source and the same verified `.love`
payload. The Windows branch exists to develop and verify the Windows artifact in
parallel with the current macOS release line.

## Automatic synchronization

Every push to `codex/world-tour-v1` triggers
`.github/workflows/sync-windows-version.yml`. The workflow:

1. checks out `codex/windows-version`;
2. merges the latest `codex/world-tour-v1` commit;
3. runs the full LuaJIT regression suite and luacheck;
4. runs a LÖVE boot smoke and the desktop portability audit;
5. pushes the verified merge to `codex/windows-version`.

The workflow never force-pushes and never discards Windows-specific commits. A
merge conflict or failed verification stops synchronization and leaves the last
verified Windows branch intact, with the failed workflow as the visible alert.

## Change routing

- Shared gameplay, content, interface, media, save, and engine fixes land in
  `codex/world-tour-v1` first and flow forward automatically.
- Windows-only packaging or target integration lands in
  `codex/windows-version`.
- If Windows testing reveals a shared runtime bug, fix it in
  `codex/world-tour-v1`; do not leave a divergent gameplay patch only in the
  Windows branch.
- Do not automatically merge `codex/windows-version` back into
  `codex/world-tour-v1`.

## Delivery boundaries

Branch synchronization proves source alignment and shared regression health. It
does not prove a native Windows build, signing, clean-machine compatibility, a
published release, or public-live availability. Those states require the
desktop distribution and release-verification gates.
