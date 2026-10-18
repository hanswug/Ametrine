# Profiling baseline

Phase 0 baseline (handover §5.0). Question: when Amethyst feels slow or quirky, is the cost inside Amethyst, or is an app flooding it with Accessibility notifications?

## Baseline: 2026-10-10

| | |
|---|---|
| Build | `hw-Amethyst` (fork at `093deec`, functionally upstream `6508ee2`), Release |
| Machine | personal Mac, macOS 27.0, Xcode 27.0, Ark display |
| Method | Instruments Time Profiler attached to the running app, 20 min of normal work (`xctrace record --attach`) |

**Result: Amethyst is essentially idle. There's no measurable cost and no flood.**

- **CPU:** 274 ms over 20 min (≈ 0.02 %), 84 % of it on the main thread.
  - 220 ms of that fell in the first minute; every later minute stayed under 15 ms.
- **Hangs:** Instruments' potential-hangs table recorded none. The main thread was never unresponsive for ≥ 250 ms.
- **Terminal stall:** Hans noticed one about 3 min in. Amethyst used 1–7 ms of CPU per minute around then, so it wasn't the cause.
- **Where the little CPU went (inclusive):**
  - AX notification handling (`ApplicationObservation.handle`): 55 ms.
  - Computing active windows per screen (`Windows.activeWindows(onScreen:)`): 51 ms. It filters every window via `AXWindow.screen()` / `frame` / `pid()`, each an AX IPC round trip.
  - `application(_:didMoveWindow:)`: 38 ms.
  - Mouse drag-swap (`swapDraggedWindowWithDropzone`): 26 ms.
  - Reflow (`ScreenManager.setNeedsReflow`): 18 ms.
- **AX notification flood:** no sign of one. A flood would show up as sustained CPU in `observerCallback` → `ApplicationObservation.handle`, and the total was 55 ms in 20 min. A separate per-app notification count (`--log`) was therefore skipped.

### What this doesn't rule out

Time Profiler only samples threads that are **running**. When Amethyst waits on a synchronous AX call to an app that is busy or hung, its thread is blocked, not running, so the wait barely shows up as CPU. Such waits would cause sluggish tiling without CPU cost. If they reached 250 ms on the main thread, they would appear as potential hangs; none did in this session. The slowdown is occasional and simply didn't happen during this recording.

## Phase 2: listing a screen's windows (2026-10-18)

Question (code audit, C1/C2): is `activeWindows(onScreen:)` worth making cheaper? It runs in every layout pass and in every focus, swap and warp command.

**Method.** Time Profiler can't answer this: the cost is waiting for other apps' Accessibility replies, which it barely sees (above). Instead, a throwaway branch logged wall-clock times with `--log` around `activeWindows(onScreen:)` (split into its Space lookup, frame and checks), `windowSet(forWindows:)`, each command and each layout pass. Two sessions of about 10 minutes each, normal work plus bursts of focus, warp and swap keys, on the big screen. The rule was set before measuring: change the code only if `activeWindows` plus the focus lookup take ≥ 10 ms at the 95th percentile per command, or ≥ 30 % of a command. The timing patches are kept locally in `build/profiles/`.

**Before** (6.5.3): 685 calls, 11 windows checked per call (median), 4 on this Space and screen. Per command, `activeWindows` plus the focus lookup took 6.3 ms median and **21.8 ms at p95**, so the rule said go. A layout pass spent 45 % of its time there. The worst single call took 110 ms, because one app took 86 ms to answer a `pid()` request.

**The audit's fix would have saved nothing.** It proposed checking floating, hidden and active first, but those checks ask the apps too (`id()` and `pid()`), so the estimated cost per call stayed 2.16 → 2.15 ms. What works instead:

- **C1, revised:** a window not on the window server's on-screen list (another Space, minimised) is left out before its Space and frame are asked for. The list is cached and the window ID is cached by Silica, so the check is free, and the result is the same, since the list is already part of the "active" condition.
- **C2:** the focused window is looked up once per window set instead of once per window.

**After** (6.5.4): the pre-filter skipped all 4 windows that weren't on this Space or screen (median). The focus lookup per window set went from 0.45 to 0.13 ms median and from 4.4 to 0.46 ms at p95. Per command, `activeWindows` plus the focus lookup went from **21.8 to 11.8 ms at p95 (−46 %)**, and every command measured dropped, for example warp 11.5–17.5 → 6.3–12.9 ms median. The sessions differed (8 windows per call after, 11 before), so the comparison was also made per window and command by command. No new errors.

**What's left:** a focus key takes about 18–36 ms in total, mostly the focusing itself (bringing the app forward, moving the cursor), not listing windows. Nothing here is noticeable; the gain is fewer requests to other apps.

## Phase 3: asking apps for a window's pid (2026-10-18)

Question (second code audit, P1): every `window.id()` calls `pid()`, which asked the window's app for `AXParent`, one Accessibility round trip each time. The focus handler runs on the main thread and calls `id()` on every tracked window several times (`isWindowTracked`, `refreshWindow`, `recordFocus`). Is that worth fixing?

**Method.** Same as phase 2: a throwaway branch (`build/profiles/measure-pid.patch`) counted and timed each `AXParent` request per thread and logged it with `--log` per focus event, command and layout pass. Same rule, set before measuring: change the code only if the requests take ≥ 10 ms at p95, or ≥ 30 %, of a focus event or a command. One session before (about 6 minutes, 8 tracked windows) and one after (about 4 minutes, 4–6 windows), normal work plus bursts of focus, warp and swap keys. For the after session the patch was applied on top of the change and counts only the requests still made.

**Before** (6.5.4): per focus event (56 events), 27 requests at the median (4.75 per tracked window), taking 3.3 ms median and **22.0 ms at p95: 57 % of the event's time**, on the main thread. Commands (115): 11 requests, 1.2 ms median, 5.2 ms p95, 7 % of their time. Layout passes (165): 20 requests, 9 %. The focus events met the rule; commands and passes didn't.

**The change:** an element's parent can't change process, so `AXWindow` keeps the pid once `AXParent` has answered (`CachedPID`, locked, since Accessibility is called from several threads). Without an answer it uses the element's own pid, as before, and asks again next time.

**After:** per focus event 2 requests (0.4 per tracked window), 0.09 ms median and 0.3 ms at p95; per command 1 request, 0.1 ms; per layout pass none. A focus event took 0.6 ms median instead of 6.3 ms, but only 6 focus events arrived in the after session: apps send `focusedWindowChanged` only when focus moves between two windows of the same app, and that session had fewer windows. The request counts are the solid part of the comparison. No new errors; the manual tests passed in the trial.

## When the slowdown happens again

1. As soon as it feels slow, run `scripts/profile.sh 5m` and keep doing whatever triggered it.
   - It attaches Time Profiler to the running `Ametrine` and saves the trace to `build/profiles/`.
   - It then prints CPU per thread and per minute, the top self and inclusive frames, and the potential hangs (`scripts/analyze-time-profile.py`).
2. Read the result:
   - **High CPU in `observerCallback` / `ApplicationObservation.handle`, especially `didMoveWindow`/resize:** an app is flooding notifications. Find it with step 3.
   - **Potential hangs with `mach_msg` at the bottom of the main-thread stack:** Amethyst is blocked on a slow app's AX reply. Open the trace in Instruments and see which AX call; `-[SIAccessibilityElement …]` frames name the attribute.
   - **High CPU in `activeWindows(onScreen:)` / `windowSet(forWindows:)`:** the per-reflow window filtering is the cost. Since 6.5.4 windows not on screen are skipped first (Phase 2 above); waiting time doesn't show here, so measure wall-clock time the same way.
   - **Nothing in Amethyst:** look elsewhere (WindowServer, the app itself), e.g. Activity Monitor or Instruments "All Processes".
3. Per-app notification count (only if step 2 points at a flood):
   - Quit Ametrine and start it with logging, written to a file: `open --stdout build/profiles/ametrine.log --stderr build/profiles/ametrine.log -a /Applications/Ametrine.app --args --log`. (Launching through `open` keeps it a normal app launch; started directly from a terminal it may not pick up every app.)
   - Reproduce, then count `Received notification for window:` lines grouped by window ID.
   - Map the IDs to apps with the window list, e.g. `/Applications/Ametrine.app/Contents/MacOS/Ametrine debug windows --include-unmanaged`.

In zsh, `log` is a shell built-in; use `/usr/bin/log` for macOS's unified log. Amethyst's own messages appear there redacted (`<private>`), hence the file above.

## Known issue found while profiling

`Amethyst debug windows` used to exit with SIGTRAP (status 133) in `Windows.run()`, in the fork and in upstream 0.24.3 alike: Finder lists the desktop (an `AXScrollArea`) among its windows, and the force-unwrap `AXWindow(element: window)!` in `Amethyst/Debug/WindowsInfo.swift` failed on it. Fixed in hw-Amethyst 2.4.x: such elements print as `<not a window: role …>`. The command runs in the calling process, so the terminal needs Accessibility permission; without it, it says so and exits.
