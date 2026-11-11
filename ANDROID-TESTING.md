# Android Phase I testing

## Build status

A debug Android APK has been built and its signature and 16 KB alignment checks passed. The package and build evidence are recorded in PHASE-I.md. Native gameplay validation remains pending; the browser preview alone does not establish native compatibility.

## Phone installation

Use the debug APK supplied with the build report. Open it on the Android device and allow installation from the specific app used to open it if Android asks. Alternatively, with USB debugging enabled and the phone connected to the development PC, install with Android platform-tools:

`adb install -r PATH_TO_APK`

Accept the phone's debugging authorization prompt yourself. A debug-signed build is for testing; the Play release will use studio-controlled signing.

## Chromebook installation

Prefer a Google Play internal-testing link when the studio account is ready. Local ADB installation may be possible through the Chromebook's Linux development environment, depending on device and management settings. Do not switch ChromeOS into Developer Mode just for this test. Provide the Chromebook model, ChromeOS version, Play availability, and whether it has touch so the correct installation route can be selected.

## Device checklist

- [ ] Launch and reach the title screen without a crash.
- [ ] Check that pixel edges are crisp and proportions are unchanged.
- [ ] Check that the entire game is visible, with patterned wallpaper in unused space.
- [ ] Open and scroll the tutorial, then enter gameplay.
- [ ] Tap one monster and then an adjacent monster to swap. Repeat near all board edges.
- [ ] Match monsters, summon them, and select a spell card when available.
- [ ] Pause and resume with the pause button. Test Android Back separately.
- [ ] Leave the app for the home screen, return, and confirm gameplay waits for Resume.
- [ ] Complete or lose a run. Tap TYPE INITIALS (or an initial) to open the Android keyboard. Enter up to three characters; lowercase becomes uppercase. Save score / keyboard Done submits; Cancel leaves the prior initials and score screen unchanged. The in-game SAVE SCORE button uses the displayed initials.
- [ ] Check keyboard focus, visibility, three-character paste/typing limit, Back to hide/dismiss, blank/short initials, and re-opening after cancellation. Check that the native dialog remains usable in landscape.
- [ ] With a physical keyboard, retain arrow/WASD selection and X/Space/Enter confirmation outside the native editor.
- [ ] Replay and return to the title without a keyboard or internet connection.
- [ ] Fully close and reopen the app; confirm tutorial status, initials, and local high scores persist.
- [ ] On Chromebook, repeat the flow using mouse/trackpad and keyboard and resize the app window.
- [ ] Check audio, long-session performance, and unusual heating or battery drain.

## Expected limitations

Phase I keeps the landscape composition. There is no portrait rearrangement or layout setting yet. Active runs remain in memory only; if Android terminates the process, that run is lost. Scores and tutorial progress are saved separately. the studio approved this original save behavior for Phase I; full run recovery is deferred.

## Developer checks

In debug builds, F5 opens victory, F6 opens spell selection while the board is idle, and F7 opens defeat. F5 was already present; F6/F7 allow repeatable native smoke tests without waiting for a full run. These shortcuts are excluded from release builds. On an emulator, Android keycodes 135, 136, and 137 correspond to F5, F6, and F7.

Build with `./tools/Build-Android.ps1`. The script accepts SDK, NDK, and Java path overrides. Verified dependencies: Haxe 4.3.6, HaxeFlixel 6.1.2, flixel-addons 4.0.1, Lime 8.3.1, OpenFL 9.5.1, hxcpp 4.3.2, NDK r28c, SDK 36, and Java 21. The project-local compatibility wrappers support the older hxcpp Windows tool naming without editing shared dependencies.

## Report problems

Include device model, OS version, what you did, what happened, and whether it happens every time. For layout issues include the orientation and whether the Chromebook app was windowed or full screen. Screenshots or a short recording are useful, but not required.
