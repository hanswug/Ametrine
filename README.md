# Ametrine

**All the tiling, none of the rabbit hole.**
What you see is what you move.

Layouts built for real productivity, not the feeling of it: your main window big, the rest beside it, and never more than you can follow, from a single window to about eight. Each layout is a way of working you already know; pick the three or four that fit you and learn them well. Focus, swap and warp any window up, down, left or right, on keys you choose, and the menu bar tells you what's going on. No trees to rebalance, no split ratios to babysit, no rule for every app. A complex config feels like progress; it isn't the work.

**Start from a real config.** Ametrine comes with mine, the one I work with every day: every setting and every key in one file, each setting with its options and default right beside it. Change what you like without going back and forth to the docs.

**Where's the app? Everywhere.** Ametrine has no window of its own: it sits in the menu bar, works on every window you have, and leaves what it doesn't do (free placement, launching) to the tools that do it well.

Built on [Amethyst](https://github.com/ianyh/Amethyst) by Ian Ynda-Hummel, for anything from a laptop to a 55" 4K screen; padding modes can even make a huge display behave like a smaller one.

> **No public releases:** builds are self-signed, not notarised. [Build it yourself](#getting-started) in a few minutes.

## Highlights

- **Layouts for real work**, most with a mirror-image twin. → [Layouts](docs/layouts.md)
- **Focus, swap and warp by direction:** h/j/k/l, the arrows or any keys you bind. → [Directional navigation](docs/directional-navigation.md)
- **The layout's state in the menu bar:** `M: ●○` for main's places, `S: 4` for a stack. → [Feedback](docs/features.md#feedback)
- **Flip:** mirror a layout, or reverse its rows or columns. → [Flip](docs/layouts.md#flip)
- **Padding modes:** virtual screens on a big display, per Space. → [Padding modes](docs/features.md#padding-modes)
- **Palette, shortcut sheet and URL:** every command searchable, your keys at a glance, `ametrine://` for scripts. → [Palette](docs/features.md#command-palette)
- **Calm windows:** dialogs float, a window limit keeps tiles readable, windows snap back. → [Features](docs/features.md)
- **Focus border:** a soft glow that follows the focused window. → [Focus border](docs/features.md#focus-border)
- **Light on your other apps:** half as long waiting on them as the Amethyst code it came from, measured. → [Profiling](docs/PROFILING.md#phase-2-listing-a-screens-windows-2026-10-18)

**Design principles:** main first · built for real work · by direction, not by order · keyboard first · no hidden state · workflows, not mechanics · no tricks · not an all-in-one. → [What each one means](docs/principles.md)

## Getting started

1. **Signing certificate (once per Mac):** a self-signed Code Signing certificate named `Amethyst Local Signing`, made in Keychain Access ([how](docs/development.md#requirements)).
2. **Build:** `scripts/build.sh` (needs Xcode and `brew install swiftlint`) installs `/Applications/Ametrine.app`. Grant Accessibility when asked.
3. **Config:** copy [ametrine.sample.yml](ametrine.sample.yml) to `~/.config/ametrine/ametrine.yml`. **Edit Config…** in the menu opens it, **Reload Config** applies it.
4. **First keys:** bind `show-command-palette` and the `focus-<direction>` keys. The palette runs the rest until you know what you use.

Working on Ametrine itself: [development](docs/development.md).

## Configuration

The sample is my own config: every setting and command in sections, each with its options and default in a comment. A key reads like this:

```yaml
mod1: [control, option]                  # everyday: focus, layouts
focus-west: {mod: mod1, key: h}          # the key is the direction, the modifier the verb
focus-east: {mod: mod1, key: l}
show-shortcuts: {mod: <NONE>, key: <NONE>}   # unbound; the palette still runs it
```

Every setting and command: [configuration-files.md](docs/configuration-files.md).

## Layouts

Pick the 3 or 4 that match how you work and learn them well. I use four, plus Floating for free placement: [my setup](docs/my-setup.md).

- **Main and a stack:** Tall, Wide, Widescreen Tall
- **Main between columns:** 3Column, 4Column
- **One at a time, or two side by side:** Fullscreen, Two Pane
- **Split evenly:** Column, Row, BSP
- **No tiling:** Floating

Most come in mirror-image twins (Left/Right, Top/Bottom). How main works, with a diagram of each: [layouts](docs/layouts.md).

## Documentation

- [Layouts](docs/layouts.md): how main works, and every layout with diagrams
- [My setup](docs/my-setup.md): the layouts I use, and when
- [Features](docs/features.md): everything Ametrine does
- [Design principles](docs/principles.md): what it's for, and what it isn't
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
