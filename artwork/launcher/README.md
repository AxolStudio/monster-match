# Later cropped artwork references

These existing files preserve the later cropped 6x6 character treatment: `play-icon-512.png`, `play-icon-512.svg`, and `icon-preview.png`. They are reference-only and do not describe the historical local build26 APK/AAB launcher, which uses the full framed 8x8 source.

No historical listing PNG is available in the diagnostic snapshot. These files have not been relabeled as historical or regenerated. The later generator and 21-path vectors remain recoverable in commit `e654bf8e572cf08ceb338aa9c891c9218c0ac63a` and branch `codex/integrate-android-build26-20261111`.

`tools/Build-LauncherIcon.ps1` is restored historical generation source. Running it would overwrite listing files here as well as Android vectors. It was not run during source preservation. `tools/Preview-LauncherIcon.ps1` previews the current vectors when explicitly invoked; the stored preview here is still the later cropped reference.
