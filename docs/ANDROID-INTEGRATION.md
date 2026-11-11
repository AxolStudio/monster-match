# Monster Match Android source integration, 2026-11-11

This candidate preserves the Android phase-two source and all 43 pending source/assets from the original worktree. It overlays the seven individually hash-verified build26 diagnostic files plus their project version, while retaining newer cropped-icon artwork, generation script and tests from the worktree. The original checkouts and historical packages remain unchanged.

Private handoff links, device/conversation details, signing-storage paths, generated build products and caches are excluded from the public snapshot. Existing studio art is preserved rather than regenerated. Archived artwork and achievement hashes were verified; the two mobile-intro files also match the merged Fish & Chips source and have explicit hashes.

## Platform boundaries and fixes

- Play Games JNI/UI, native initials entry, Android SDK dependency and manifest integration are guarded by android. Desktop service methods remain no-ops.
- The new six-event reporting helper had unintentionally also called Axol analytics on desktop. Its imports are now Android-only, and its methods require android and not debug. The real helper fails the new inert-service desktop regression before the fix and passes release/debug after it. Existing desktop Axol scores/save behavior is retained.
- The old app build="26" attribute was ignored by Lime and generated versionCode 25. It is corrected to build-number="26"; the generated and merged manifests now report versionCode 26/versionName 1.0.5.
- Build26 initializes Play Games from Application.onCreate, reports only fixed diagnostic stages/numeric SDK status, and rejects stale or cancelled foreground UI retries.
- The executable basename is MonsterMatch. axollib remains at 6aa05f11c30b8011827933c3e9e77ab38986a201.

## Fresh validation

- Windows/Neko release builds passed with and without -Dkiosk. Windows C++ target Haxe compilation/code generation passed with native compilation disabled.
- Android release Haxe compilation/C++ code generation passed with native compilation disabled. Existing key-loading dependencies were used only for local compilation, without displaying or changing their contents.
- Generated desktop configuration and service code exclude the Android bridge and new count-event calls.
- Four Haxe interpreter suites passed: achievement catalog, game-event catalog, local scores and pointer presentation.
- Five pure Java suites passed: account progress/isolation, auth diagnostics, game-event ownership, initials normalization and platform UI lifecycle.
- Play Games configured/unconfigured/duplicate-ID gates and real-resource validation passed. This does not prove live Console linkage or authentication.
- Launcher-icon tests passed for original colors/pixels, cropped mask, adaptive safe circle and opaque listing art.
- Desktop event-boundary test passed in release and debug using the actual helper and inert service mocks. It reads no real keys and makes no network calls.
- Android real-SDK Java compilation and merged manifest processing passed offline, one worker/512 MB heap, 39 tasks. Java 8/JDK 21 and deprecated API warnings remain.
- AndroidManifestTest passed for version, application initializer, removed unconditional SDK init provider, API 24 minimum and API 36 target.
- Signing/build scripts parse successfully. The release script now requires an explicit signing directory; no signing operation ran.
- Independent review found no remaining important source defect after the two fixes and public-documentation cleanup.

## Remaining release verification and dependencies

The existing desktop loader and release event helper depend on pre-existing keyfiles. Those files and their loader remain unchanged from master; no new credential changes are included in this snapshot. Fresh local compilation used the existing setup. Reproducing those targets requires the same developer-provided dependencies, so this report does not claim credential-free desktop reproducibility.

Flixel 6.1.2 and flixel-addons 4.0.1 are project-pinned. Current selected dependencies are Lime 8.3.1, OpenFL 9.5.1 and hxcpp 4.3.2, but those versions remain machine-selected, so reproduce that toolchain explicitly.

No new native Windows link, full Android native package, signing, emulator/hardware gameplay session, or live Google authentication/account-switch test was performed. Historical reports describe their original builds only. Do not treat this as release certification. No itch.io or Google Play deployment was performed.
