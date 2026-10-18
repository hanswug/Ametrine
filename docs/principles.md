# Design principles

What Ametrine is for, and what it deliberately isn't. Every feature is checked against these.

- **Main first.** The window you work in is the centre of every layout; the others are there to be brought in.
- **Built for real work.** Ametrine is shaped around how people actually work, not around every arrangement a tiling engine could make.
  - **A few layouts, learned well.** Each layout is a way of working you already know: one thing in focus with references beside it (Tall), many windows around a centre (3Column Middle), one or two at a time on a laptop (Fullscreen, Two Pane). Pick the 3 or 4 that match you and learn them thoroughly.
  - **A screen holds what you can follow.** Around 8 windows, a mental grid of 4 by 2, is as many as most people keep track of. A 9th window is usually a quick lookup (let it float) or a different task (give it another Space).
  - **Productivity, not the feeling of it.** No trees to rebalance, no split ratios to babysit, no rule for every app. A complex config feels like progress; it isn't the work.
  - **Limits that help.** A window limit can float or minimise the windows past it, and the counts in the menu bar show how full main and the stacks are, so you notice before the screen gets crowded.
- **By direction, not by order.** You reach the window next to you, not the next one in a list. No clockwise order to remember, no Alt-Tab.
- **Keyboard first.** Every command can have a key, and the palette shows them all while you build the muscle memory.
- **No hidden state.** A window is either visible or deliberately gone; nothing is parked where you have to remember it.
- **Workflows, not mechanics.** Features exist for a way of working, not to show off a tiling algorithm. BSP is there, but main is the centre.
- **No tricks.** Ametrine does what macOS allows: no System Integrity Protection changes, nothing injected into the Dock or other apps. Where macOS has no public API that works, Ametrine uses private calls the way other window managers do, for three things only: reading what the public API doesn't tell (which Space a window is on, a window's shape and moves for the focus border), drawing its own windows (the border), and focusing the window you asked for.
- **Not an all-in-one.** Ametrine tiles, and leaves the rest to apps that do it well. Each display and each Space is tiled on its own, with no commands to move windows between them (macOS has no public API for moving a window to another Space), and free-floating windows are placed by a window mover such as Raycast.
