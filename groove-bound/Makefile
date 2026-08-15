# Groove Bound developer targets. Run from the groove-bound/ directory.

LUA ?= luajit
PYTHON ?= python3

.PHONY: run test lint package package-macos package-windows clean

run:
	love .

test:
	$(LUA) tests/run.lua

lint:
	luacheck src main.lua conf.lua tests

# Build a deterministic public .love with release-only controls enabled.
package:
	$(PYTHON) scripts/package_love.py

# Build a universal macOS app, ZIP, and DMG with the Groove Bound icon.
# Requires the official LÖVE 11.5 app at /Applications/love.app.
package-macos: package
	scripts/build_macos_release.sh

# Build the self-contained Windows x64 ZIP from an extracted official runtime.
package-windows: package
	$(PYTHON) scripts/build_windows_release.py --runtime-dir "$(LOVE_WINDOWS_RUNTIME)"

clean:
	$(PYTHON) scripts/clean_dist.py
