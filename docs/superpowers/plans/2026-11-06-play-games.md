# Play Games integration and presentation plan

> **For agentic workers:** Use superpowers:executing-plans inline. User asked to proceed ASAP; continue through the buildable work without interim approval stops.

**Goal:** Add optional achievements, leaderboard and friends comparison; improve icon; restore full Axol animated intro.
**Architecture:** Project-local Android Java extension bridges Play Games Services v2 through Lime JNI. Game events remain platform neutral; existing Newgrounds triggers are preserved. Native Google leaderboard/achievement screens avoid squeezing social tables into the pixel canvas.
**Scope:** Cloud saves excluded; Game Stats undecided; morphing deferred. No publishing, purchases, account resource creation or assumed Console access.

- [x] Confirm official SDK APIs, pinned version, friends consent and absent-service behavior.
- [x] Add and test stable mapping for the 12 existing achievement events and final scores.
- [x] Implement Android extension with empty disabled configuration, graceful offline/unavailable behavior, explicit friends consent, lifecycle-safe UI, and resource-ID mapping. Preserve local saves/scores and never wait for a network response to continue gameplay.
- [x] Connect original event hooks and add optional Awards/Scores title actions and Friends action after game over. The 12 mappings are unit-tested; actual server delivery for every trigger requires configured live testing.
- [x] Retain earned achievement events locally for retry after sign-in; do not send debug-forced outcomes as real accomplishments. Explain leaderboard best-score comparison.
- [x] Improve launcher icon using the existing studio pixel-art identity and Android-safe sizing. Inspect actual assets; no inferred screenshot contents.
- [x] Use the full animated Axol Studio intro as the studio clarified. Investigate existing debug bypass, preserve intro aspect and wallpaper.
- [x] Build Android/web; verify signature/alignment, native unavailable-service path, intro and icon; obtain final code review.
- [x] Document Console project/achievement/leaderboard IDs, package/signing fingerprints/testers required for live testing. Missing real credentials are a live-service validation blocker, not a reason to leave local implementation unfinished.

## Findings

Official Google Maven metadata reports play-services-games-v2 22.1.0 as latest release. Friends collection is supported, but requires player consent. Friends comparison will use Google's native leaderboard UI from the post-game local score screen and compares leaderboard personal bests. It will not expose private friend data without consent.


Restoring the full intro exposed a Flixel debug BitmapLog.clear stale-index crash at the next state transition. The actual-engine regression failed before the project-local index reset and passed afterward. The guarded macro leaves shared dependencies unchanged. Review found no Important/Critical issues in the bridge or this compatibility fix; native retesting is required before delivery.

## Authorized privacy-audit correction

the studio approved correcting the device-wide pending-progress attribution discovered during policy review. Added AccountProgress and AccountSession with owner-partitioned persistence, fixed run origins, explicit anonymous-history claims and identity epochs. Legacy originals are preserved and migrated once into unassigned history; no sign-in silently adopts them. SDK identity is checked immediately before dispatch; captured owner/epoch rejects stale completions. Pure-Java tests progressed from missing-class RED to GREEN for A/B isolation, acknowledgements, restart, migration, claims, fixed run origin and stale A→B/A→A tokens. Review found no Important/Critical issues. The revised native build is in progress; live SDK account switching still needs real Console configuration.

Privacy handoff is PLAY-GAMES-DATA-FLOWS.md. It explicitly records allowBackup=true/no exclusions, no in-game reset, and that Google-side deletion does not clear app-local history. No destructive account/data tests or publishing were performed.

Final revised Android build succeeded. Signature, ZIP/ELF alignment and update-save preservation pass. Native smoke covers complete intro-to-title, original icon in launcher, all unavailable-service buttons, a touch match, Back pause, Home/resume, local score save after a debug defeat, debug-report suppression and replay; no HXCPP/AndroidRuntime errors. APK SHA-256 354073C55EC3ED649DC4DB6F00242F907D1F22FAE243778D4C70F750DDA46AEB. Live service acceptance remains blocked on genuine Console configuration/testers; no claim that all 12 awards were delivered to Google.
