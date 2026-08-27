# omarchy-screensaver-nix

Omarchy's ASCII screensaver, extracted from [basecamp/omarchy](https://github.com/basecamp/omarchy) so you can import it into a NixOS config via **Hjem / Hjem Rum and/or Home Manager**. Same `programs.omarchyScreensaver` options either way.

Idle session → fullscreen terminal per monitor → your logo (or any PNG/SVG converted to braille) running through [ttfx](https://github.com/omacom-io/ttfx) effects. Colors follow the live [Noctalia](https://github.com/noctalia-dev/noctalia) v5 palette by default. Any key or mouse movement exits.

This is **not** a port of the whole Omarchy desktop. It is the screensaver: launch scripts, terminal configs, KWin/Plasma shortcut, Noctalia v5 idle drop-in, Hyprland rules, and a declarative module for every knob Omarchy exposes.

## What you get

| Piece | Role |
| --- | --- |
| `omarchy-screensaver` | Inner loop: `ttfx` against your art until dismissed |
| `omarchy-screensaver-launch` | One fullscreen terminal per monitor (KWin or Hyprland) |
| `omarchy-screensaver-toggle` | Disable the idle screensaver without removing the module |
| `omarchy-screensaver-ascii` | PNG/SVG → braille or block glyphs (ImageMagick) |
| `programs.omarchyScreensaver` | Declarative art, effects, idle, bind, colors |

Designed for **KWin + Noctalia v5** and **Hyprland + hypridle**. `compositor = "auto"` installs both session files; launch detects which compositor is running. Needs one of **Kitty, Ghostty, Foot, or Alacritty** (Kitty is the smoothest on KWin: `--start-as-fullscreen`).

## Add the flake

```nix
# flake.nix
{
  inputs.omarchy-screensaver.url = "github:luxus/omarchy-screensaver-nix";
}
```

### Hjem / Hjem Rum

Same extraModule slot Noctalia uses. `rum.programs.omarchyScreensaver` is an alias of `programs.omarchyScreensaver`.

```nix
hjem.extraModules = [
  inputs.hjem-rum.hjemModules.default          # if you use rum.*
  inputs.omarchy-screensaver.hjemModules.default
];

hjem.users.<name>.programs.omarchyScreensaver = {
  enable = true;
  compositor = "auto"; # kwin + hyprland files; launch detects the session
  terminal = "kitty";

  # Pick one. Priority: image > file > text > bundled Omarchy wordmark.
  art.image = ./logo.png;          # PNG or SVG, converted at build time
  # art.file = ./screensaver.txt;
  # art.text = ''hello'';

  art.width = 80;
  art.height = 26;
  art.mode = "braille"; # or "block"
  art.threshold = 50;   # raise if the conversion is a blob
  # art.invert = true;  # light logo on dark background

  effects = {
    mode = "random"; # or "single"
    # single = "matrix";
    # include = [ "matrix" "rain" "decrypt" "beams" "wipe" ];
    exclude = [ "bouncyballs" ];
  };

  idle = {
    backend = "noctalia"; # drop-in ~/.config/noctalia/zz-omarchy-screensaver.toml
    timeout = 150;        # seconds since idle began
    lockTimeout = 300;    # native Noctalia lock; null to skip
  };

  bind = "Meta+Esc";            # Plasma X-KDE-Shortcuts
  hyprland.bind = "SUPER, Escape";

  appearance.noctalia.enable = true;           # default — follow the Hjem/Noctalia palette
  appearance.noctalia.background = "terminal_background";
  appearance.noctalia.foreground = "terminal_foreground"; # or "primary"
};
```

Noctalia v5 merges every `*.toml` in `~/.config/noctalia/` alphabetically. The module writes `zz-omarchy-screensaver.toml` so it only touches idle **and** screensaver user templates — your bar, theme, and lock styling stay yours.

The idle drop-in is:

```toml
[idle]
behavior_order = ["screensaver", "lock", "screen-off", "suspend"]

[idle.behavior.screensaver]
timeout = 150
action = "command"
command = "omarchy-screensaver-launch"

[idle.behavior.lock]
timeout = 300
action = "lock"
```

Set `idle.writeBehaviorOrder = false` if you already own `behavior_order`. Unlisted names are appended, so without that list the screensaver would run *after* lock.

### NixOS module (package + overlay only)

```nix
{
  imports = [ inputs.omarchy-screensaver.nixosModules.default ];
  programs.omarchyScreensaver.enable = true; # puts omarchy-screensaver on PATH
}
```

Session wiring (art, idle, shortcut) still lives in the Hjem or Home Manager module.

### Home Manager

```nix
home-manager.sharedModules = [
  inputs.omarchy-screensaver.homeManagerModules.default
];
```

Then the same `programs.omarchyScreensaver = { ... };` attrset as above. See [examples/home.nix](examples/home.nix).

## Module options

All options live under `programs.omarchyScreensaver` (Hjem extraModule, rum alias, or Home Manager).

### Art

| Option | Default | Notes |
| --- | --- | --- |
| `art.text` | `null` | Inline ASCII |
| `art.file` | `path` | Path to a `.txt` |
| `art.image` | `path` | PNG/SVG, converted with `omarchy-screensaver-ascii` |
| `art.width` / `art.height` | `80` / `26` | Terminal cells for image conversion |
| `art.mode` | `"braille"` | `"block"` for `█▀▄` |
| `art.threshold` | `50` | 0–100; the usual fix for a muddy conversion |
| `art.invert` | `false` | Light-on-dark source images |
| `art.trim` | `true` | Drop empty margins |

### Effects (ttfx)

`mode = "random"` (Omarchy default) or `"single"`.

`--include-effects` and `--exclude-effects` cannot be combined (ttfx constraint).

Effects: `beams`, `binarypath`, `blackhole`, `bouncyballs`, `bubbles`, `burn`, `colorshift`, `crumble`, `decrypt`, `errorcorrect`, `expand`, `fireworks`, `highlight`, `laseretch`, `matrix`, `middleout`, `orbittingvolley`, `overflow`, `pour`, `print`, `rain`, `randomsequence`, `rings`, `scattered`, `slice`, `slide`, `smoke`, `spotlights`, `spray`, `swarm`, `sweep`, `synthgrid`, `thunderstorm`, `unstable`, `vhstape`, `waves`, `wipe`.

### Noctalia themes

`appearance.noctalia.enable` (default **true**) registers four [Noctalia v5 user templates](https://docs.noctalia.dev/noctalia/theming/app-theming/):

```toml
[theme.templates.user.omarchy_screensaver_kitty]
input_path  = "$XDG_CONFIG_HOME/omarchy-screensaver/templates/kitty.conf"
output_path = "$XDG_CONFIG_HOME/omarchy-screensaver/terminals/kitty.conf"
```

Same for Ghostty, Alacritty, and Foot. When you change the Hjem/Noctalia palette — builtin (Tokyo Night, Catppuccin, Nord, …), a community palette, or wallpaper Material You — Noctalia re-renders those terminal configs. The screensaver does **not** need a rebuild.

Tokens (see [template reference](https://docs.noctalia.dev/noctalia/theming/templates/)):

| Option | Default | Other useful values |
| --- | --- | --- |
| `appearance.noctalia.background` | `terminal_background` | `surface`, `background` |
| `appearance.noctalia.foreground` | `terminal_foreground` | `primary`, `on_surface`, `on_background` |

Set `appearance.noctalia.enable = false` to bake `appearance.background` / `foreground` hex at build time instead.

Confirm Noctalia sees the templates:

```bash
noctalia theme --list-templates
```

### Idle

Timeouts are **seconds since idle began**, not chained — same model as Omarchy's `shell.json` and Noctalia v5.

| Option | Default | Notes |
| --- | --- | --- |
| `idle.backend` | `"noctalia"` | `"hypridle"` or `"none"` |
| `idle.timeout` | `150` | Screensaver |
| `idle.lockTimeout` | `300` | Native Noctalia lock, or hypridle `lockCommand` |
| `idle.manageLock` | `true` | Write the lock behavior |
| `idle.writeBehaviorOrder` | `true` | Screensaver before lock in Noctalia |

`omarchy-screensaver-toggle` writes `~/.local/state/omarchy-screensaver/off` so idle launches become no-ops; `omarchy-screensaver-launch force` still works (Meta+Esc by default).

### KWin / Plasma

Kitty and Ghostty start fullscreen themselves. Foot/Alacritty rely on the same app-id plus whatever window rule you already use.

`bind = "Meta+Esc"` installs `~/.local/share/applications/omarchy-screensaver.desktop` with `X-KDE-Shortcuts`. Plasma picks that up as a custom application shortcut. Re-login or `kquitapp6 kglobalaccel` if it does not bind on first switch.

### Hyprland

`compositor = "auto"` (the default) or `"hyprland"` writes `~/.config/hypr/omarchy-screensaver.conf`. The Home Manager module `source`s it from `extraConfig` when the HM Hyprland module is on; under Hjem, source it yourself.

Hyprland **0.53+** needs the new rule syntax (`ruleSyntax = "new"`, the default). Both `float` and `fullscreen` are required. For Hyprland `< 0.53` set `hyprland.ruleSyntax = "legacy"`. Hyprland bind is `hyprland.bind = "SUPER, Escape"` — a different string from the Plasma shortcut.

## Commands

```bash
omarchy-screensaver-launch          # idle entry; no-ops if toggled off
omarchy-screensaver-launch force    # Meta+Esc / menu
omarchy-screensaver-toggle          # enable / disable idle screensaver
omarchy-screensaver-toggle status
omarchy-screensaver-ascii logo.svg ~/.config/omarchy-screensaver/art.txt --width 100
```

## Manual / Stylix hex

If you are not using Noctalia templates, bake colors at build time:

```nix
programs.omarchyScreensaver.appearance = {
  noctalia.enable = false;
  background = "1a1b26";
  foreground = "c0caf5";
};
```

## Layout on disk

```
~/.config/omarchy-screensaver/art.txt                 # generated art
~/.config/omarchy-screensaver/config                  # env sourced by the scripts
~/.config/omarchy-screensaver/templates/              # Noctalia user-template sources
~/.config/omarchy-screensaver/terminals/              # rendered (or baked) terminal configs
~/.config/noctalia/zz-omarchy-screensaver.toml        # idle drop-in + theme.templates.user.*
~/.config/hypr/omarchy-screensaver.conf               # compositor auto / hyprland
~/.local/share/applications/omarchy-screensaver.desktop
~/.local/state/omarchy-screensaver/off                # toggle flag
```

## Credits

Screensaver behavior, ASCII transcoder, and terminal configs are adapted from [basecamp/omarchy](https://github.com/basecamp/omarchy) (DHH / Basecamp). Effects are [ttfx](https://github.com/omacom-io/ttfx), a Rust port of [TerminalTextEffects](https://github.com/ChrisBuilds/terminaltexteffects) by ChrisBuilds.
