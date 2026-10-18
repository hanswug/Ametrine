# Performance

Ametrine uses almost no CPU. What can make a tiling window manager feel slow is waiting: every window's position, size and owner is an Accessibility request to the app that owns the window, and a busy app answers late. So the performance work is about asking apps less, and every change is measured first.

## How it's measured

- **CPU:** Instruments Time Profiler attached to the running app during normal work (`scripts/profile.sh`). A 20-minute session on the fork's first build used 0.02 % CPU and recorded no hangs.
- **Waiting:** a profiler barely sees time spent blocked on another app, so waits are measured as wall-clock time. A temporary build logs how long each focus change, command and layout pass takes, and how many requests it sends to apps. One session of normal work before a change, one after.
- **A rule set before measuring:** code changes only if the cost reaches 10 ms at the 95th percentile, or 30 % of the operation. A proposed speed-up that would have saved 3–5 % of a command was dropped by this rule.

## What was resolved

| Version | Problem | Fix | Result |
|---|---|---|---|
| 6.5.4 | Listing a screen's windows checked every tracked window on every Space, asking the window server for its Space and its app for its frame, and looked up the focused window once per window | Windows that aren't on screen are skipped first, using the window server's on-screen list; the focused window is looked up once | Time per command 21.8 → 11.8 ms at the 95th percentile (−46 %) |
| 6.5.5 | Every window lookup asked the window's app which process owns it. A focus change did that about five times per open window, on the main thread: 57 % of its time, 22 ms at the 95th percentile | The answer is kept per window, since a window can't change process | A focus change sends 2 requests instead of about five per window; 22 → 0.3 ms at the 95th percentile |

## If Ametrine feels slow

1. While it's slow, run `scripts/profile.sh 5m` from a source checkout and keep doing what triggered it. It records a Time Profiler trace to `build/profiles/` and prints CPU per thread and per minute, the top frames and any potential hangs.
2. Read the result:
   - **Sustained CPU in `ApplicationObservation.handle`, especially for moves and resizes:** an app is flooding Ametrine with notifications. Step 3 finds which.
   - **Potential hangs with `mach_msg` at the bottom of the main thread:** Ametrine is waiting on a slow app. In Instruments, the `-[SIAccessibilityElement …]` frames name the request.
   - **Nothing in Ametrine:** look at the app itself or WindowServer (Activity Monitor, Instruments "All Processes").
3. Notifications per app: quit Ametrine, start it with `open -a /Applications/Ametrine.app --args --log`, reproduce, then count the `Received notification for window:` lines in `~/Library/Logs/Ametrine/Ametrine.log` by window ID. `/Applications/Ametrine.app/Contents/MacOS/Ametrine debug windows --include-unmanaged` maps the IDs to apps.
