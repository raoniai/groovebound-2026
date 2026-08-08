# Groove Bound developer targets. Run from the groove-bound/ directory.

LUA ?= luajit

.PHONY: run test lint package clean

run:
	love .

test:
	$(LUA) tests/run.lua

lint:
	luacheck src main.lua conf.lua tests

# Build a distributable .love (a zip of the game folder).
package: clean
	mkdir -p dist
	zip -9 -r dist/groove-bound.love . \
		-x "dist/*" -x "tests/*" -x "docs/*" -x "design-system/*" \
		-x "Makefile" -x ".luacheckrc" -x "*.md" \
		-x "scripts/*" \
		-x ".DS_Store" -x "*/.DS_Store" -x "assets/generated/*-source.png" \
		-x "assets/generated/source-candidates/*" \
		-x "assets/video/*.mp4" \
		-x "music/*" \
		-x "docs/screenshots/*"

clean:
	rm -f dist/groove-bound.love
