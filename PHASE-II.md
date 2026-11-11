# Phase II landscape polish: historical report

Development on November 6, 2026 continued the Android Phase I source. This is historical build evidence, not fresh validation of the integrated snapshot. See docs/ANDROID-INTEGRATION.md for current checks.

## Changes preserved

- The original 10x10 brick tile repeats into margins with integer zoom and no smoothing.
- Touch hides the custom cursor. Synthesized mouse movement is suppressed for 750 ms; real mouse input can restore the cursor, including after title transitions.
- PixelBitmapText refreshes metrics before sizing to avoid stale first-draw center/right text alignment in HaxeFlixel 6.1.2. Shared dependency files remain unchanged.
- The enemy counter moved three game pixels upward. Its outlined bottom is row 41, above the zone title at row 42.
- Adaptive portrait rearrangement, rotation confirmation, and saved layout modes remain deferred. The supported composition remains landscape.

## Historical verification

The development report recorded successful ARM64/x86-64 native builds and an API 30 emulator install, with retained tutorial/initials/scores. Touch matching, cursor return, pause and title transitions were exercised. Bitmap-text and counter bounds regressions failed before fixes and passed afterward. The counter regression changed from bottom row 44 overlapping title row 42 to bottom row 41 above it. Signature and static 16 KB alignment checks passed on those historical APKs.

No new native gameplay, physical-device, authentication or signing claim is made by this report. Chromebook play, extended sessions, actual account flows and release artifacts still need acceptance checks. Android process death ends an active run; durable local scores and tutorial progress remain separate.
