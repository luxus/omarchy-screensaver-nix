# omarchy-screensaver-nix

Omarchy's ASCII screensaver, extracted from [basecamp/omarchy](https://github.com/basecamp/omarchy) so you can import it into a NixOS / Home Manager config.

Idle Hyprland session → fullscreen terminal per monitor → your logo (or any PNG/SVG converted to braille) running through [ttfx](https://github.com/omacom-io/ttfx) effects. Any key or mouse movement exits.

This is **not** a port of the whole Omarchy desktop. It is the screensaver: launch scripts, terminal configs, Hyprland window rules, hypridle listeners, and a Home Manager module for every knob Omarchy exposes.

## What you get

| Piece | Role |
| --- | --- |
| `omarchy-screensaver` | Inner loop: `ttfx` against your art until dismissed |
| `omarchy-screensaver-launch` | One fullscreen terminal per Hyprland monitor |
| `omarchy-screensaver-toggle` | Disable the idle screensaver without removing the module |
| `omarchy-screensaver-ascii` | PNG/SVG → braille or block glyphs (ImageMagick) |
| `programs.omarchyScreensaver` | Declarative art, effects, idle, bind, colors |

Requires a Hyprland session and one of **Kitty, Ghostty, Foot, or Alacritty**.

## Add the flake

```nix
# flake.nix
{
  inputs.omarchy-screensaver.url = "github:luxus/omarchy-screensaver-nix";
}
```

### Home Manager (recommended)

Works with standalone HM or HM-as-a-NixOS-module. For a flake-parts setup like `luxus/flakes`:

```nix
# nixosConfigurations.<host> modules
inputs.home-manager.nixosModules.home-manager
{
  home-manager.sharedModules = [
    inputs.omarchy-screensaver.homeManagerModules.default
  ];
}
```

Then in the user module (`hosts/vanessa/home.nix`):

```nix
{
  programs.omarchyScreensaver = {
    enable = true;
    terminal = "kitty"; # or ghostty / foot / alacritty / auto

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
      timeout = 150;       # seconds since idle began
      lockTimeout = 300;   # independent of screensaver
      lockCommand = "loginctl lock-session";
    };

    bind = "SUPER, Escape"; # force-start even if idle screensaver is off
  };
}
```

### NixOS module (package + overlay only)

```nix
{
  imports = [ inputs.omarchy-screensaver.nixosModules.default ];
  programs.omarchyScreensaver.enable = true; # puts omarchy-screensaver on PATH
}
```

Session wiring (window rules, hypridle, art) still lives in Home Manager.

## Module options

All options live under `programs.omarchyScreensaver`.

### Art

| Option | Default | Notes |
| --- | --- | --- |
| `art.text` | `null` | Inline ASCII |
| `art.file` | `null` | Path to a `.txt` |
| `art.image` | `null` | PNG/SVG, converted with `omarchy-screensaver-ascii` |
| `art.width` / `art.height` | `80` / `26` | Terminal cells for image conversion |
| `art.mode` | `"braille"` | `"block"` for `█▀▄` |
| `art.threshold` | `50` | 0–100; the usual fix for a muddy conversion |
| `art.invert` | `false` | Light-on-dark source images |
| `art.trim` | `true` | Drop empty margins |

### Effects (ttfx)

`mode = "random"` (Omarchy default) or `"single"`.

`--include-effects` and `--exclude-effects` cannot be combined (ttfx constraint).

Effects: `beams`, `binarypath`, `blackhole`, `bouncyballs`, `bubbles`, `burn`, `colorshift`, `crumble`, `decrypt`, `errorcorrect`, `expand`, `fireworks`, `highlight`, `laseretch`, `matrix`, `middleout`, `orbittingvolley`, `overflow`, `pour`, `print`, `rain`, `randomsequence`, `rings`, `scattered`, `slice`, `slide`, `smoke`, `spotlights`, `spray`, `swarm`, `sweep`, `synthgrid`, `thunderstorm`, `unstable`, `vhstape`, `waves`, `wipe`.

### Idle

Same model as Omarchy's `shell.json`: both timeouts are **seconds since idle began**, not chained.

Defaults: screensaver at 150s, lock at 300s. Dismissing the screensaver cancels the pending lock (activity). `omarchy-screensaver-toggle` writes `~/.local/state/omarchy-screensaver/off` so hypridle launches become no-ops; `omarchy-screensaver-launch force` still works (bound to Super+Esc by default).

`idle.manageHypridle` appends listeners through `services.hypridle.extraConfig` so it does not clobber your existing `settings.listener` list. Set it `false` if you want to wire:

```
timeout = 150
on-timeout = omarchy-screensaver-launch
```

yourself.

### Hyprland

Writes `~/.config/hypr/omarchy-screensaver.conf` and, when the HM Hyprland module is present, `source`s it from `extraConfig`.

Hyprland **0.53+** needs the new rule syntax (`ruleSyntax = "new"`, the default):

```
windowrule = match:class org.omarchy.screensaver, float on
windowrule = match:class org.omarchy.screensaver, fullscreen on
```

Both `float` and `fullscreen` are required — fullscreen of a tiled window is just a big tile.

For Hyprland `< 0.53` set `hyprland.ruleSyntax = "legacy"`.

## Commands

```bash
omarchy-screensaver-launch          # idle entry; no-ops if toggled off
omarchy-screensaver-launch force    # Super+Esc / menu
omarchy-screensaver-toggle          # enable / disable idle screensaver
omarchy-screensaver-toggle status
omarchy-screensaver-ascii logo.svg ~/.config/omarchy-screensaver/art.txt --width 100
```

## Stylix

Point colors at your scheme if you want the terminal to match:

```nix
programs.omarchyScreensaver.appearance = {
  background = config.lib.stylix.colors.base00;
  foreground = config.lib.stylix.colors.base05;
};
```

## Layout on disk

```
~/.config/omarchy-screensaver/art.txt      # generated art
~/.config/omarchy-screensaver/config       # env sourced by the scripts
~/.config/omarchy-screensaver/terminals/   # alacritty / ghostty / foot
~/.config/hypr/omarchy-screensaver.conf    # window rules + bind
~/.local/state/omarchy-screensaver/off     # toggle flag
```

## Credits

Screensaver behavior, ASCII transcoder, and terminal configs are adapted from [basecamp/omarchy](https://github.com/basecamp/omarchy) (DHH / Basecamp). Effects are [ttfx](https://github.com/omacom-io/ttfx), a Rust port of [TerminalTextEffects](https://github.com/ChrisBuilds/terminaltexteffects) by ChrisBuilds.
