# Monster Match Windows Arcade Implementation Plan

**Goal:** One fullscreen Windows test package usable by keyboard alone or gamepad alone, retaining pointer play and preserved Android behavior.
**Architecture:** Desktop-only focus/input helpers call existing UI callbacks and board selection/swap logic. The board cursor follows spatial cells rather than movable block IDs. Existing Android branches and dependency versions remain unchanged. Hosted regression uses isolated storage and no network; production is compiled but never run by CI.
**Tech stack:** Haxe4.3.7, Lime8.3.2, OpenFL9.5.2, hxcpp4.3.2, Flixel6.2.1 (latest upstream tag verified November12), addons4.0.1. Android retains Flixel6.1.2.
**Authorization:** Existing ten-game modernization request and repeated direction to proceed; no publication. Routine input design is the implementer's choice, not a new user-approved specification.

## Constraints
- Baseline304c6eb preserves merged Android source plus historical icon restoration; no claim of identity to the Google submission.
- No Android build/submission; no itch deployment; no native builds/game launches on Lewton.
- Never upload private keyfiles, signing material or broad credential snapshots to GitHub. No live telemetry from tests.
- Single identical fullscreen Windows artifact for itch and GameLauncher. Private Drive test delivery only.

## Interfaces
- DesktopInput: static sample(elapsed:Float):DesktopFrame; frame has dx:Int,dy:Int,accept:Bool,back:Bool,pause:Bool,neutral:Bool. Read once per active state/update, including analog repeat/deadzone. No synthetic mouse movement.
- DesktopFocus: new(count:Int,initial:Int=0); index:Int; update(frame:DesktopFrame):Bool returns accept after neutral gate, wrap deterministic navigation; state owner paints focused target.
- All new modules and additions compile only under desktop. Existing callbacks remain shared unless desktop offline score flow requires a guarded alternative.

## Tasks
- [ ] Write red pure tests for input repeat/neutral gating and focus transitions; implement desktop helpers. Add guarded title/help/credits/pause/confirm navigation and separate Exit defaulting Cancel.
- [ ] Add spatial board focus/selection/swap, visible cursor, cancellation, spell selection and initials controls. Exercise real handlers in isolated native tests, never by faking successful gameplay outcomes.
- [ ] Audit existing API contract, remove broad keyfile embedding from desktop build path without altering Android. Preserve legitimate scores while ensuring offline retry never waits on network. Fail closed on unverifiable game registration.
- [ ] Add Windows dependency/fullscreen guards, preserve submodule pin with exact committed CI snapshot if private checkout requires it, preserve Android projection and all assets/extensions.
- [ ] Run existing pure/renderer tests plus keyboard/gamepad real-loop smoke, retry, return-to-title, Exit and offline service boundaries on GitHub Windows runner. Apply bitmap reentry guard only with native evidence and retain existing width fix.
- [ ] Independent review; build production compile-only, hash package, upload verified private Drive candidate. Report physical controller/hotplug, cabinet focus and live API limits honestly.

## Review focus
- Held accept must not cross modal boundaries or accidentally confirm Exit.
- Board objects move/refill: navigation must address physical cells, not stale IDs.
- Initials, spell choices and retry must be accessible without mouse or network.
- Offline or failed service requests cannot block play or contaminate regression saves.
- Android projections include dependency/gamepad defines, macros and source, not only icon hashes.
