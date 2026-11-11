# Play Games data flows â€” implementation evidence, November 6, 2026

This is a developer handoff for privacy-policy drafting, not a published policy or a claim that live Google integration has been verified. Application, twelve achievement and leaderboard IDs are now configured. The November 6 beta tracking addition below documents the newly enabled Axol reporting and Google Game Stats event path. Legacy Google Events IDs remain blank. Cloud saves are excluded.

## Local data

- Original game save `MonsterMatch-userData.sol` retains tutorial progress, player initials and the device-wide top-ten score table. The framework's separate `MonsterMatch.sol` can contain sound/debug UI preferences when those engine features write them. Existing extra/legacy save fields are preserved. These are separate from Google reporting. The current run is not recovered after process termination.
- Android private SharedPreferences `monster_play_games` retain achievement-event flags, highest completed score, successful achievement acknowledgements and highest acknowledged score, partitioned under an encoded Google Play Games player ID. The encoding is a reversible key format, not encryption. Player display name is used in memory for the confirmation dialog, not persisted by this bridge.
- Runs started without a confirmed current player use a separate unassigned partition. Unassigned awards and best score remain locally until explicitly claimed. Local leaderboard initials are never used to infer a Google identity.
- Earlier development queues (`earned_*`, `pending_score`) migrate once to unassigned progress. Their original keys and old acknowledgement keys remain preserved but are no longer used for automatic attribution. A migration flag prevents importing them again after a claim.
- In-memory state includes the current verified identity, a run's fixed originating identity, identity/request generations and pending callbacks. Pause invalidates verified identity and callback tokens; the run's originating identity stays fixed. There is no device-wide session best reused across accounts.

## Association and transmission

At run start, the bridge snapshots the currently confirmed player. A run started anonymously stays unassigned even if authentication completes during play. A run started as A stays A-owned if the selected account later becomes B. New B runs are B-owned after identity confirmation. Unverified play remains available offline.

For a matching selected player, original achievement events and a completed score are queued locally, then submitted using Google's achievements/leaderboard APIs. Queues retry after that same player authenticates/resumes and when matching events or explicit score-screen requests occur. The SDK's authenticated current player is checked immediately before dispatch. Owner and identity-generation tokens are captured; stale completions cannot acknowledge work or open screens for a later identity. Pending A events are not sent while B is selected.

Unassigned progress is never uploaded merely because someone signs in. After an explicit AWARDS, SCORES or FRIENDS action authenticates a player, a native dialog names the selected profile and describes the unassigned achievement count and best score. **Keep on device** retains it without assigning it. **Add to this profile** explicitly transfers all currently unassigned progress to that profile after another SDK identity check. Leaving/pausing dismisses the dialog without transfer. It does not change the owner of an already-running anonymous run; later events from that run remain unassigned. There is no automatic per-person inference for a shared device.

The bridge sends Google-generated achievement IDs and the game's integer final score through the SDK for the selected profile, plus the six count events described below. It does not upload the local initials table, tutorial flags, current board or saved run. Google handles authentication and its own SDK/network data; this source audit is not a complete SDK telemetry audit.

The Android build disables the Newgrounds build flag and legacy Axol score-upload path. The requested dual event reporting now initializes AxolAPI and persists a game-local GUID; see the tracking addition below.

The optional Friends action asks Google's consent flow when required, requests a minimal friends page to resolve access, releases the returned player buffer, then opens Google's native all-time friends leaderboard. This bridge does not persist friends lists or names. Google's native UI/service displays profile and leaderboard information according to Google's settings and consent. No custom friends server exists.

## Retry, switching and deletion

Failed/unacknowledged uploads stay associated with their original owner. Successful acknowledgements are saved for that owner; score retries send only a best score higher than its acknowledged best. An upload dispatched before an account switch or pause may still complete at Google; the app cannot retract that already-dispatched request. Its stale callback is ignored. A later retry for the same original profile is idempotent (unlock once / highest-score leaderboard).

Switching to B retains A's local pending and acknowledged history but does not offer it as B's unassigned history. Signing back into the same A player ID makes A's pending work eligible for retry. If Google returns a different player ID, old queues stay under the old ID and are not silently reassigned.

Deleting Google Play Games data does **not** clear this app's local saves, pending queues, acknowledgements or legacy originals. The app has no deletion notification hook. Previously acknowledged events are not intentionally resubmitted solely because server data was deleted, but outstanding/new events can upload again when the same player authenticates. Do not promise that deleting Google data prevents later submissions or deletes local history.

There is currently **no in-game reset/delete control**. Android's app-storage controls can clear local app data; clearing/uninstalling is a user action, not performed in these tests. Google-side data is managed separately. No real user accounts or user saves were deleted during development.

## Backup

The merged manifest currently has `android:allowBackup="true"` and no project backup/data-extraction exclusions. Subject to Android, device and account rules, system backup/device transfer may include the local saves and reporting preferences, including player-ID partitions. The bridge does not implement its own backup service or cloud save. Restored local history remains partitioned; it must not be described as cleared merely because Google game data was deleted. System backup can affect whether old app data reappears after reinstall/transfer. No backup or cross-device restore has been tested.

## Verification and remaining decisions

Pure-Java tests pass for separate A/B queues and acknowledgements, persistence/restart, non-destructive legacy migration, explicit unassigned claims, fixed run ownership, anonymous runs after sign-in, and stale tokens including Aâ†’B and Aâ†’A reauthentication. Existing UI lifecycle tests pass. These are local deterministic tests, not live SDK acceptance tests.

Application, achievement and leaderboard IDs are configured. Linked package/signing credentials and tester access still need live verification, followed by authentication, every achievement, score acceptance, two-account switching, anonymous claim UI, friends consent granted/denied, deleting Google game data and backup/restore behavior. Game Stats schemas require Console import; legacy Events IDs are optional and currently blank. Any deletion tests must use explicitly disposable test accounts/data with authorization. Nothing has been published by this executor.

No product decision blocks the conservative implementation: unassigned history is retained until explicit selection. the studio may later choose an in-game deletion control or backup exclusions; neither is implemented or promised by this handoff. The privacy policy must describe the actual defaults above until those choices are made and verified.
# November 6 beta tracking addition â€” pending live verification

The new Android release initializes the existing Axol API for the requested dual reporting. It persists a random game-local GUID in the existing save and submits six named integer-count events (game_started, monster_summoned, hero_defeated, spell_cast, game_completed, victory) to https://axolstudio.com/api/2.0/add/event, with event_time, event_name, player_id, game_id and value. Google player identity is not sent to Axol. Debug builds suppress these new events. Existing Axol packet behavior is reused; no new deletion or retention control is promised.

The same six events use Google GameStatsClient with an INT64 amount property, once the draft Console schemas are imported. Legacy EventsClient uses separately generated event IDs; blank IDs skip that destination. At dispatch the bridge requires the run's original player to match the currently authenticated player and rechecks SDK identity. Anonymous/unverified events are not retrospectively assigned to Google profiles. No application-level retry queue is added for additive increments, to avoid blindly duplicating counts; SDK buffering applies after acceptance. Local Counts/results and gameplay remain independent. These statistics may therefore omit events that occur without verified Google identity. No claim of complete offline Google analytics is made.

This changes the earlier Android-no-Axol-network baseline. Review the privacy policy/Data safety statements before testing beyond the internal track. Console schema acceptance, Google delivery, actual account switching and backend Axol receipt have not yet been verified live.

Integration boundary: the six new count events are Android-only and excluded from debug builds. Desktop retains its original Axol score/save behavior, without the new event reporting.
