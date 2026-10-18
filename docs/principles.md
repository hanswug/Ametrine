# Design principles

What Ametrine is for, and what it deliberately isn't. Every feature is checked against these.

- **Main first.** The window you work in is the centre of every layout; the others are there to be brought in.
- **By direction, not by order.** You reach the window next to you, not the next one in a list. No clockwise order to remember, no Alt-Tab.
- **Keyboard first.** Every command can have a key, and the palette shows them all while you build the muscle memory.
- **No hidden state.** A window is either visible or deliberately gone; nothing is parked where you have to remember it.
- **Workflows, not mechanics.** Features exist for a way of working, not to show off a tiling algorithm. BSP is there, but main is the centre.
- **Realistic.** A handful of layouts you actually use beats every possible arrangement, and a screen holds the windows you can work with. More is a sign to close or float something: a window limit can float or minimise the windows past it, and the counts in the menu bar show how full main and the stacks are.
- **No tricks.** Ametrine does what macOS allows: no System Integrity Protection changes, nothing injected into the Dock or other apps. Where macOS has no public API that works, Ametrine uses private calls the way other window managers do, for three things only: reading what the public API doesn't tell (which Space a window is on, a window's shape and moves for the focus border), drawing its own windows (the border), and focusing the window you asked for.
- **Not an all-in-one.** Ametrine tiles, and leaves the rest to apps that do it well. Each display and each Space is tiled on its own, with no commands to move windows between them (macOS has no public API for moving a window to another Space), and free-floating windows are placed by a window mover such as Raycast.
