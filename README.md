# Ametrine

> **Ametrine is no longer developed: I've moved to [OmniWM](https://github.com/OmniNull/OmniWM)** (my fork: [hanswug/OmniWM](https://github.com/hanswug/OmniWM)). Why: speed (instant, and a workspace switch never re-tiles your windows), an active upstream that gives real feedback, and building it together with its maintainer and contributors. Ametrine still works as it is, and its releases stay available.

**All the tiling, none of the rabbit hole.**
What you see is what you move.

**Realistic layouts, for real productivity.** Your main window big, the rest beside it, and never more than you can follow, from a single window to about eight. Each layout is a way of working you already know; pick the three or four that fit you and learn them well. No trees to rebalance, no split ratios to babysit, no rule for every app. A complex config feels like progress; it isn't the work.

**Up, down, left, right.** Focus, swap and warp any window in the direction you see it, on keys you choose, and the menu bar shows the layout's state (`M: ●○ | Tall Left`).

**Start from a real config.** Ametrine comes with mine, the one I work with every day: every setting and every key in one file, each setting with its options and default right beside it. Change what you like without going back and forth to the docs.

**Too many keys? Bind a few.** The command palette runs every command by name, and the shortcut sheet shows the keys you did bind at a glance, with focus, swap and warp in one grid.

**Where's the app? Everywhere.** Ametrine has no window of its own: it sits in the menu bar, works on every window you have, and leaves what it doesn't do (free placement, launching) to the tools that do it well.

Built on [Amethyst](https://github.com/ianyh/Amethyst) by Ian Ynda-Hummel, for anything from a laptop to a 55" 4K screen; padding modes can even make a huge display behave like a smaller one.

> **[Download the latest release](https://github.com/hanswug/Ametrine/releases/latest)** · macOS 12 or later, tested on macOS 27 with one display · self-signed, not notarised, so the first launch needs **Open Anyway** ([how](#getting-started)).

## Highlights

- **Layouts for real work**, most with a mirror-image twin. → [Layouts](docs/layouts.md)
- **Focus, swap and warp by direction:** h/j/k/l, the arrows or any keys you bind. → [Directional navigation](docs/directional-navigation.md)
- **The layout's state in the menu bar:** `M: ●○` for main's places, `S: 4` for a stack. → [Feedback](docs/features.md#feedback)
- **Flip:** mirror a layout, or reverse its rows or columns. → [Flip](docs/layouts.md#flip)
- **Padding modes:** virtual screens on a big display, per Space. → [Padding modes](docs/features.md#padding-modes)
- **Palette, shortcut sheet and URL:** every command searchable, your keys at a glance, `ametrine://` for scripts. → [Palette](docs/features.md#command-palette)
- **Calm windows:** dialogs float, a window limit keeps tiles readable, windows snap back. → [Features](docs/features.md)
- **Focus border:** a soft glow that follows the focused window. → [Focus border](docs/features.md#focus-border)
- **Light on your other apps:** measured, listing windows waits on your apps half as long as the Amethyst code it came from, and a focus change asks them twice instead of about five times per open window. → [Performance](docs/PROFILING.md)

**Design principles:** main first · built for real work · by direction, not by order · keyboard first · no hidden state · workflows, not mechanics · no tricks · not an all-in-one. → [What each one means](docs/principles.md)

## Getting started

1. **Download:** `Ametrine-<version>.zip` from the [latest release](https://github.com/hanswug/Ametrine/releases/latest). Unzip it and move `Ametrine.app` to Applications. Quit Amethyst or any other tiling window manager; never run two at once.
2. **Config first:** copy [ametrine.sample.yml](ametrine.sample.yml) (also attached to each release) to `~/.config/ametrine/ametrine.yml`. Ametrine runs on its config file and won't start without one.
   ```bash
   mkdir -p ~/.config/ametrine && curl -fsSL https://raw.githubusercontent.com/hanswug/Ametrine/fork/main/ametrine.sample.yml -o ~/.config/ametrine/ametrine.yml
   ```
3. **Open it:** Ametrine is signed with my own certificate, not notarised by Apple, so macOS blocks the first launch. Go to System Settings → Privacy & Security and click **Open Anyway**. Then grant Accessibility when asked; updates keep it, since every release has the same signature.
4. **First keys:** the sample binds the command palette to ⌃⌥P and focus to ⌃⌥ + h/j/k/l. The palette runs everything else until you know what you use. **Edit Config…** in the menu opens the file, **Reload Config** applies it.

**Build it yourself** instead: make a self-signed Code Signing certificate named `Amethyst Local Signing` in Keychain Access ([how](docs/development.md#requirements)), then `scripts/build.sh` (needs Xcode and `brew install swiftlint`) builds and installs `/Applications/Ametrine.app`.

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
