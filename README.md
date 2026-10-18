# Ametrine

A tiling window manager for macOS, designed around the **main pane**: the window you're working in gets the big tile, and everything else lines up beside it.

**Layouts from real work, not a tiling rabbit hole.** Tiling can turn into a hobby: trees to rebalance, split ratios to tune, a rule for every app. Ametrine skips that. Each layout is a way of working you already know: one thing in focus with references beside it (Tall), many windows around a centre (3Column Middle), two side by side or one at a time on a laptop (Two Pane, Fullscreen). Pick the 3 or 4 that match how you work, learn them, and get on with your day. They stay readable because they stay realistic: around 8 windows is as many as most people keep track of, and a window limit can float or minimise the ones past it.

**Move what you see, in the direction you see it.** h/j/k/l focuses the window to the west, south, north or east (or the arrow keys, if Vim keys aren't yours); with another modifier the focused window swaps or warps there. What's on your left is one key to the left: no clockwise order to keep in your head, no Alt-Tab.

**See the layout's state instead of guessing it.** The menu bar shows the layout and what it can't show by itself: `M:●○ | Tall Left` is one window in main and room for the next, `S:4 | Fullscreen` is four windows in the stack. And any window can tell you why it tiles or floats.

**One documented file instead of settings windows.** Every setting and every command sits in a single config, each with its options and default, and this repo documents the rest. Nothing hides in preference panes, and nothing is left over from an earlier setup.

Ametrine is built on [Amethyst](https://github.com/ianyh/Amethyst) by Ian Ynda-Hummel. It was born out of the need to handle many windows on large displays, such as a 4K 55" screen or an ultrawide, and to stay simple on a standard one, a single 27" 5K or a laptop's built-in display, where a full-screen stack or two panes side by side is all it takes. That range is where its flexibility comes from: the same setup works from a huge display to a standard one, and padding modes can even make the huge one behave like a smaller screen.

> **There are no public releases.** Builds are signed with a self-signed certificate, not notarised (that needs a paid Apple Developer ID). You can [build it yourself](#getting-started) in a few minutes.

## Highlights

- **Layouts built around main.** Tall, Wide, Two Pane, 3Column, 4Column, Widescreen Tall, Column, Row, Fullscreen, Floating and BSP, each named by where main is, and each with a mirror-image twin. → [Layouts](docs/layouts.md)
- **Move by direction.** h/j/k/l (or the arrow keys) with one modifier focuses the window to the west, south, north or east; with another the window warps or swaps there. → [Directional focus, swap and warp](docs/directional-navigation.md)
- **Layout state in the menu bar.** Main's places as dots (`M:●○`, filled for a window, open for room) and the stack's size in Fullscreen and Two Pane (`S:4`), before the layout's name. → [Feedback](docs/features.md#feedback)
- **Flip.** Mirror the layout, or reverse the rows or columns, to bring the windows at the far end closer. → [Flip](docs/layouts.md#flip)
- **Padding modes.** Virtual monitors on a big display, such as a centred 27" or a 21:9 strip, picked per Space. → [Padding modes](docs/features.md#padding-modes)
- **Command palette and URL.** Every command, searchable, with its key; and `ametrine://command/<key>` for scripts and launchers. → [Palette](docs/features.md#command-palette)
- **Shortcut sheet.** Your own keys at a glance, with the direction grid that shows the modifier rule. → [Shortcut sheet](docs/features.md#shortcut-sheet)
- **Calm windows.** Settings and dialogs float on their own, a window limit keeps the tiles readable, and windows snap back to their tiles. → [Features](docs/features.md)
- **Focus border.** A soft glow around the focused window that follows its corners. → [Focus border](docs/features.md#focus-border)
- **One config file.** No preferences window and no built-in keys: the file binds what you use. → [Configuration](docs/configuration-files.md)

## Design principles

- **Main first.** The window you work in is the centre of every layout; the others are there to be brought in.
- **By direction, not by order.** You reach the window next to you, not the next one in a list. No clockwise order to remember, no Alt-Tab.
- **Keyboard first.** Every command can have a key, and the palette shows them all while you build the muscle memory.
- **No hidden state.** A window is either visible or deliberately gone; nothing is parked where you have to remember it.
- **Workflows, not mechanics.** Features exist for a way of working, not to show off a tiling algorithm. BSP is there, but main is the centre.
- **Realistic.** A handful of layouts you actually use beats every possible arrangement, and a screen holds the windows you can work with. More is a sign to close or float something: a window limit can float or minimise the windows past it, and the counts in the menu bar show how full main and the stacks are.
- **No tricks.** Ametrine does what macOS allows: no System Integrity Protection changes, nothing injected into the Dock or other apps. Where macOS has no public API that works, Ametrine uses private calls the way other window managers do, for three things only: reading what the public API doesn't tell (which Space a window is on, a window's shape and moves for the focus border), drawing its own windows (the border), and focusing the window you asked for.
- **Not an all-in-one.** Ametrine tiles, and leaves the rest to apps that do it well. Each display and each Space is tiled on its own, with no commands to move windows between them (macOS has no public API for moving a window to another Space), and free-floating windows are placed by a window mover such as Raycast.

## Getting started

1. **Create a signing certificate (once per Mac).** In Keychain Access, Certificate Assistant → Create a Certificate…, type **Code Signing**, named `Amethyst Local Signing`, and set it to Always Trust for code signing.
2. **Build and install.** With Xcode and SwiftLint (`brew install swiftlint`), run `scripts/build.sh`. It installs `/Applications/Ametrine.app` and launches it. Grant it Accessibility when asked.
3. **Add a config.** Copy [ametrine.sample.yml](ametrine.sample.yml) to `~/.config/ametrine/ametrine.yml` and edit it. The menu's **Edit Config…** opens it and **Reload Config** applies it. Without a config file, Ametrine shows where it looked and quits.
4. **Bind a few keys first:** `show-command-palette`, the `focus-<direction>` keys and `swap-main`. The palette runs everything else until you know what you use.

Working on Ametrine itself: [development](docs/development.md).

## Configuration

A short example of the main settings:

```yaml
mod1: [option, control]                    # everyday: focus
mod2: [option, control, command]           # warp
mod3: [control, command]                   # swap
mod4: [option, control, shift, command]    # "Super"

layouts: [fullscreen, two-pane-a, 3column-left, 3column-middle, tall-left]

show-command-palette: {mod: mod4, key: y}

padding-modes:
  - name: full
  - name: wide
    top: 540
  - name: "27"            # quoted: a bare 27 is a number in YAML
    left: 640
    right: 640
    top: 720
padding-mode: wide        # each Space starts on this until you pick a mode there
cycle-padding-mode: {mod: mod4, key: "0"}

floating-secondary-windows: [md.obsidian]

window-max-count: 8

focus-west:  {mod: mod1, key: h}         # h/j/k/l = direction, modifier = verb
focus-south: {mod: mod1, key: j}
focus-north: {mod: mod1, key: k}
focus-east:  {mod: mod1, key: l}
warp-west:   {mod: mod2, key: h}
warp-south:  {mod: mod2, key: j}
warp-north:  {mod: mod2, key: k}
warp-east:   {mod: mod2, key: l}
swap-west:   {mod: mod3, key: h}
swap-south:  {mod: mod3, key: j}
swap-north:  {mod: mod3, key: k}
swap-east:   {mod: mod3, key: l}

focus-cw: false           # unbound, same as leaving it out or <NONE>
```

[ametrine.sample.yml](ametrine.sample.yml) is a complete, real config: every setting with its options and default, every command, in sections. Every setting and command is described in [configuration-files.md](docs/configuration-files.md).

## Layouts

| Layout | Key | What it does |
|---|---|---|
| Tall Left / Right | `tall-left`, `tall-right` | Main on the left (or right), the rest stacked in rows beside it |
| Wide Top / Bottom | `wide-top`, `wide-bottom` | Main on top (or at the bottom), the rest in columns below (or above) it |
| Two Pane A / B | `two-pane-a`, `two-pane-b` | Main plus one visible secondary pane; every other window waits behind it |
| 3Column Left / Middle / Right | `3column-left`, `3column-middle`, `3column-right` | Main plus two side columns |
| 4Column Left / Right | `4column-left`, `4column-right` | Four equal columns, main next to the centre, for very wide screens |
| Widescreen Tall Left / Right | `widescreen-tall-left`, `widescreen-tall-right` | Tall, but main's windows side by side |
| Column Left / Right | `column-left`, `column-right` | One column per window |
| Row Top / Bottom | `row-top`, `row-bottom` | One row per window |
| Fullscreen | `fullscreen` | Every window fills the screen, the focused one in front |
| Floating | `floating` | Nothing is tiled |
| BSP | `bsp` | Each new window splits the focused one in half |

Each pair is a twin: the same layout mirrored. **A word of advice:** don't use them all. Bind only the ones you are really going to use, learn their behaviour thoroughly, and have fun! You'll likely need only 3 or 4 of them: I use four, plus Floating for free placement. [My setup](docs/my-setup.md) shows which, and when. How they work, with a diagram of each: [docs/layouts.md](docs/layouts.md).

## Documentation

- [Layouts](docs/layouts.md): how main works, and every layout with diagrams
- [My setup](docs/my-setup.md): the layouts I use, and when
- [Features](docs/features.md): everything Ametrine does
- [Configuration file](docs/configuration-files.md): every setting and command
- [Directional focus, swap and warp](docs/directional-navigation.md)
- [Window limit](docs/window-limit.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Changelog](CHANGELOG.md)
- [Development](docs/development.md)

## Roadmap

- **Raycast extension** on top of the command URL.
- **Agent integration (MCP):** tell your AI assistant "set up my coding space".

## Credits and licence

Based on [Amethyst](https://github.com/ianyh/Amethyst) by Ian Ynda-Hummel and its contributors. MIT licence, see [LICENSE.md](LICENSE.md).
