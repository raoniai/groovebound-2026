# Desktop platform matrix

| Target | Artifact | Minimum evidence |
|---|---|---|
| Common | `groove-bound.love` | Archive, manifest, packaged boot |
| Windows x64 | Fused executable plus official DLLs and license | Native Windows boot, saves, media, input |
| macOS | Configured `.app` distributed as ZIP | Executable bits, bundle metadata, Intel and Apple Silicon evidence as applicable |
| Linux x64 | `.love` and approved AppImage/package route | Native Linux boot, case-sensitive paths, codecs, controller |

## Portability checks

- Case-colliding paths and path references.
- Windows reserved names and invalid characters.
- Executable bits and symlinks.
- Save behavior in fused and unfused mode.
- Runtime DLLs/frameworks and license files.
- OGG/OGV playback in the packaged build.
- Fullscreen, resizing, clipboard, and controller APIs.

## Later targets

Treat Windows ARM64, Linux ARM64, Android, iOS, web, and consoles as separate feasibility and acceptance matrices. Do not infer them from desktop success.
