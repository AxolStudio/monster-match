# Touch UI verification — November 6, 2026

Implemented the requested pixel-art buttons and Android keyboard initials entry. AWARDS, SCORES, FRIENDS, TYPE INITIALS and SAVE SCORE reuse the original Credits button's bevel/state pixels and the game's bitmap font. Original button assets are unchanged. Friends now fades in with the other score-screen actions.

The native editor is independent of Play Games. It selects previous initials, accepts at most three characters from the original alphabet, converts ASCII lowercase to uppercase, and offers Cancel / Save score / keyboard Done. Blank and short values remain supported. Cancel does not change the stored initials or submit a score. Existing arrow/WASD and X/Space/Enter code paths remain intact. The game still submits only the numeric score to Play Games.

This is the November 6 build25 development report. It is not fresh verification of the integrated build26 source. Current IDs are configured; live Console and authentication acceptance remain open. See docs/ANDROID-INTEGRATION.md.

## Historically verified

- Android ARM64 + x86-64 debug build succeeded; installed version 1.0.4, code 25, min API 24 / target 36.
- APK signature and 16 KB ZIP alignment passed.
- APK: `export/android/bin/app/build/outputs/apk/debug/MonsterMatch-debug.apk` (76,301,054 bytes).
- SHA-256: `C9BF49BB4F4D4AB565E65D66C1E4B3623D02D4B51CB7DE43EB0B3AB25F878D8B`.
- Actual API 30 emulator screenshots captured before/after. Title and Friends buttons visually match the existing artwork; the initials screen has explicit actions without clipping.
- Touching TYPE INITIALS opened the native editor with focus, previous text selected, and soft keyboard visible (`mInputShown=true`, `mIsInputViewShown=true`). Dialog and actions remained visible above the landscape keyboard.
- Actual soft-key taps three valid letters followed by a fourth left the original three in the field: fourth character rejected. Lowercase input was normalized to uppercase.
- Cancel preserved AAA and returned to the unsaved score screen. Back hid the keyboard; a second Back dismissed the editor; reopening worked.
- Native Save score created a row with the chosen initials. Existing AAA scores, including 405, survived the update and this flow.
- Replay worked. A subsequent run defaulted to the chosen initials. Keyboard Done saved a one-character Z entry, padded by the existing score format.
- Initials normalization, achievement mapping, local scores, pointer presentation, configuration gates, account isolation and platform UI lifecycle tests passed. Native Java API compilation passed after correcting an initial AlertDialog builder API mismatch. The first full build used that earlier generated copy and failed; the corrected full rebuild succeeded.
- No fatal exception or native crash was found in the tested app process's log. The HXCPP match was the normal `Running main function hxcpp_main` startup message.

## Limits and remaining release work

- Physical-arrow key injection did not establish visible editing in this emulator run; actual phone/Chromebook physical-keyboard acceptance remains to be checked. The existing non-touch branches were preserved.
- This APK remains debug-signed and has blank Play Games IDs. It is not the requested official testing bundle and has not been uploaded.
- The upload key has been created and verified separately; see SIGNING-RECOVERY.md. The signed bundle script is prepared but stops at the missing real Play Games configuration.
- Play Console browser inspection failed: native app enumeration timed out; browser transport closed before returning tabs, including a retry. Resource existence, OAuth linkage and tester settings could not be verified. Supply the actual Android resource export plus confirm Play App Signing certificate linkage and tester access.
