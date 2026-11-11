# Monster Match Android source integration, 2026-11-11

The original integration at 1046414289e272326cdeaf45f85f0cdb15f52f2e preserved the Android phase-two source and all 43 pending source/assets, including newer cropped-icon source. A subsequent read-only comparison with the historical local build26 APK/AAB established that their launcher instead used the full framed 8x8 icon. This source-only correction restores the two 64-path vectors and matching generator directly from the diagnostic snapshot. The original checkouts and historical packages remain unchanged.

Private handoff links, device/conversation details, signing-storage paths, generated build products and caches are excluded from the public snapshot. Existing studio art is preserved rather than regenerated. Archived artwork and achievement hashes were verified; the two mobile-intro files also match the merged Fish & Chips source and have explicit hashes.

## Platform boundaries and fixes

- Play Games JNI/UI, native initials entry, Android SDK dependency and manifest integration are guarded by android. Desktop service methods remain no-ops.
- The new six-event reporting helper had unintentionally also called Axol analytics on desktop. Its imports are now Android-only, and its methods require android and not debug. The real helper fails the new inert-service desktop regression before the fix and passes release/debug after it. Existing desktop Axol scores/save behavior is retained.
- The old app build="26" attribute was ignored by Lime and generated versionCode 25. It is corrected to build-number="26"; the generated and merged manifests now report versionCode 26/versionName 1.0.5.
- Build26 initializes Play Games from Application.onCreate, reports only fixed diagnostic stages/numeric SDK status, and rejects stale or cancelled foreground UI retries.
- The executable basename is MonsterMatch. axollib remains at 6aa05f11c30b8011827933c3e9e77ab38986a201.

## Earlier integration validation (before icon correction)

- Windows/Neko release builds passed with and without -Dkiosk. Windows C++ target Haxe compilation/code generation passed with native compilation disabled.
- Android release Haxe compilation/C++ code generation passed with native compilation disabled. Existing key-loading dependencies were used only for local compilation, without displaying or changing their contents.
- Generated desktop configuration and service code exclude the Android bridge and new count-event calls.
- Four Haxe interpreter suites passed: achievement catalog, game-event catalog, local scores and pointer presentation.
- Five pure Java suites passed: account progress/isolation, auth diagnostics, game-event ownership, initials normalization and platform UI lifecycle.
- Play Games configured/unconfigured/duplicate-ID gates and real-resource validation passed. This does not prove live Console linkage or authentication.
- The earlier launcher test passed for 21 cropped colored pixels, adaptive safe circle and opaque listing art. That test did not establish equivalence to the historical package and is superseded below.
- Desktop event-boundary test passed in release and debug using the actual helper and inert service mocks. It reads no real keys and makes no network calls.
- Android real-SDK Java compilation and merged manifest processing passed offline, one worker/512 MB heap, 39 tasks. Java 8/JDK 21 and deprecated API warnings remain.
- AndroidManifestTest passed for version, application initializer, removed unconditional SDK init provider, API 24 minimum and API 36 target.
- Signing/build scripts parse successfully. The release script now requires an explicit signing directory; no signing operation ran.
- Independent review found no remaining important source defect after the two fixes and public-documentation cleanup.

## Historical build26 source correction

- Only the two Android foreground/monochrome vectors and `tools/Build-LauncherIcon.ps1` change production source. All six launcher resource files now match the diagnostic originals; four were already identical. No generator was executed and no artwork was generated.
- `assets/icons/icon.png` remains the original 8x8 image (SHA256 `A2F6373EE9CA57844FE2FC6B8C7DFBA0BDB0B45D7A08B2F8156AAE40C9A97C7F`). Foreground and monochrome each contain 64 paths at 5dp per pixel, including the frame/backdrop, matching the audited local packages.
- The later 21-path cropped generator/resources remain in Git history at `e654bf8e572cf08ceb338aa9c891c9218c0ac63a` and the retained `codex/integrate-android-build26-20261111` branch. The original dirty worktree remains untouched. `artwork/launcher` still contains later cropped listing/preview references, not historical build26 artwork. The diagnostic snapshot had no listing copies; none have been fabricated.
- `Project.xml` remains unchanged: package `com.axolstudio.monstermatch`, version `1.0.5`, supported `build-number="26"`, minimum SDK 24 and target SDK 36. This preserves the actual package metadata, not the diagnostic project's ignored `build="26"` spelling. There is no version bump.
- Android gameplay/Google logic, existing desktop-only event guards, and desktop icon source/configuration are unchanged by this correction.
- Local APK SHA256: `C9523AC8E27F01C0D4C238324D7538203132FAB550B4DEC62EFC62570FA132ED`.
- Local AAB SHA256: `9B56216392663D7A61196CC7E9ED54875D82F5AA126465C48525502EE3515370`.
- These hashes identify audited historical local artifacts only. Their identity with any current Google Play submission has not been independently verified.

### Source-only correction validation

- `tests/LauncherIconTest.ps1` first failed against the cropped integration, then passed after restoration: all 64 source colors, exact geometry, vector dimensions, monochrome paths and safe-circle bounds. Later listing references are deliberately excluded.
- `tests/HistoricalAndroidSourceTest.ps1` passed: normalized diagnostic generator/resource hashes, original icon hash, effective package/version/SDK configuration and desktop icon boundary. Optional APK/AAB arguments also matched both audited artifact hashes. This pins the independently audited source relationship; it does not itself decode package vectors or establish Google Play identity.
- Four pure Haxe interpreter suites passed: achievement catalog, game-event catalog, local scores and pointer presentation.
- `tools/Test-DesktopGameEvents.py` passed in release and debug against inert service boundaries; no real keys or network calls.
- Play Games configuration gate fixtures and real-resource validation passed.
- No Android build, code generation, native packaging, signing, emulator/app launch, or store deployment ran for this correction. Prior build checks above are historical results, not newly rerun checks.

## Remaining release verification and dependencies

The existing desktop loader and release event helper depend on pre-existing keyfiles. Those files and their loader remain unchanged from master; no new credential changes are included in this snapshot. Fresh local compilation used the existing setup. Reproducing those targets requires the same developer-provided dependencies, so this report does not claim credential-free desktop reproducibility.

Flixel 6.1.2 and flixel-addons 4.0.1 are project-pinned. Current selected dependencies are Lime 8.3.1, OpenFL 9.5.1 and hxcpp 4.3.2, but those versions remain machine-selected, so reproduce that toolchain explicitly.

No new native Windows link, full Android native package, signing, emulator/hardware gameplay session, or live Google authentication/account-switch test was performed. Historical reports describe their original builds only. Do not treat this as release certification. No itch.io or Google Play deployment was performed.
