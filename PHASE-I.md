# Android Phase I work log

Historical development report. See docs/ANDROID-INTEGRATION.md for fresh integration checks and current limitations.

## Status — November 5, 2026

The Phase I test build is implemented and playable in an Android API 30 tablet emulator. Physical Chromebook/phone acceptance, audio listening, and Android 16 runtime checks remain open. Phase I is not signed off for release.

## Scope and implementation

- Preserve the 160 by 120 landscape composition. HaxeFlixel PixelPerfectScaleMode uses integer enlargement without smoothing or stretching.
- Repeat the original background tile behind the game to fill unused space.
- Keep Android touch, mouse, and keyboard available. Board and spell selection use camera-aware coordinates.
- Add touch initials entry and offline local high scores (best ten); disable legacy online service calls on Android. Existing web service behavior remains.
- Pause on focus loss and support Android Back for pause/resume. FlxG.android.preventDefaultKeys prevents Lime's default move-to-background action. Android 16 legacy Back opt-out remains necessary for this engine version.
- Preserve recovered high-resolution artwork unchanged under artwork/, outside bundled game assets.
- Package ARM64 and x86-64, minimum API 23, target API 36. Package name com.axolstudio.monstermatch remains provisional until studio approval.
- Keep modern NDK compatibility changes project-local: GNU-tool-name forwarding wrappers, explicit Windows host path, and runtime-only register diagnostic compatibility.

## Save behavior

Tutorial completion, initials, and local high scores persist. Returning while the process remains alive resumes through Pause. Android process termination ends the current run; full run recovery is deferred, as the studio approved. Changing the emulator's display density recreated the activity and ended its run; saved records survived. Ordinary resolution changes retained the process and game.

## Test package

- Local APK: export/android/bin/app/build/outputs/apk/debug/MonsterMatch-debug.apk
- Version 1.0.4 (21), debug signed, 100,351,973 bytes.
- SHA256: D3449EE140FD58EF945F8852769D2DF78AF52C0E8C43729D5E37B4B8AB0C58DE
- Repeatable build: ./tools/Build-Android.ps1; dependency versions and installation guidance are in ANDROID-TESTING.md.

## Verification

| Check | Result |
| --- | --- |
| Original HTML5 baseline | Built successfully before changes |
| Final HTML5 compilation | Passed |
| Local score regression tests | Passed: ordering, ten-record limit, first run, no mutation of existing records; initial missing implementation failed before implementation |
| Final native Android build | Passed for ARM64 and x86-64; Gradle BUILD SUCCESSFUL |
| APK installation | Passed in API 30 x86-64 emulator |
| APK signature / 16 KB zip alignment | Passed |
| All four packaged native ELF libraries | Every LOAD segment aligned to 16384 bytes |
| Title, tutorial entry/exit, gameplay | Exercised in browser and native emulator |
| Native touch swap and matching | Successful match, score and tube fill observed |
| Shuffle, minority removal, meteor cards | Selected by touch and returned to gameplay; debug F6 used to reach each picker |
| Native victory and defeat | Initials, local score submission, replay exercised; debug F5/F7 used to reach outcomes |
| Touch-to-mouse duplicate activation | Each initial advanced once per tap |
| Save persistence | Tutorial flag, AAA initials, and prior score survived force-stop/relaunch; second score retained alongside first |
| Android Back | Initial default-background bug reproduced, root cause identified, fixed, rebuilt, and pause/resume verified |
| Background and return | Existing pause overlay shown on return |
| Mouse / keyboard | Mouse score submission and replay, keyboard P pause and debug function keys exercised |
| Screen fit | 1280x800 at density 160 and 1920x1080 at density 240; full composition visible with wallpaper. Live resolution change retained process and accepted keyboard input |
| Runtime errors | No fatal exception or native crash found in final emulator log |
| Independent code reviews | No Critical/Important findings, including final Back and debug shortcut additions |

The SDK's emulator 37.2.13 crashed before booting Android on this host. An isolated official emulator 32.1.11/API 30 image worked; SDK emulator files were not replaced. The emulator ran without host audio. Emulator timing and host memory pressure prevent treating this as a physical-device performance benchmark.

## Remaining acceptance gates

- Real Chromebook and phone: comfortable text/touch targets, trackpad behavior, window resizing, audio, interruptions, and extended sessions.
- Newer Android/API 36 runtime and a 16 KB-page device or compatible emulator. Static alignment checks passed; runtime behavior there is unverified.
- Natural full-session progression, summoning/combat balance, and performance on physical devices. Debug outcome/spell tests are smoke tests, not full playthroughs.
- Studio approval of appearance, minimum comfortable screen size, and final package identity.
- Production signing, Play Console upload validation, and Play pre-launch reports belong to the release stage and need the studio account.

Phase II adaptive portrait/landscape layout remains deferred.
