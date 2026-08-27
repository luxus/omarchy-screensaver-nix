{
  lib,
  pkgs,
  self,
  defaultConfigDir,
}: let
  inherit (lib) mkEnableOption mkOption types;
  system = pkgs.stdenv.hostPlatform.system;
in {
  enable = mkEnableOption "Omarchy ASCII screensaver for KWin/Noctalia and Hyprland, via Hjem or Home Manager";

  package = mkOption {
    type = types.package;
    default =
      if self ? packages && self.packages ? ${system}
      then self.packages.${system}.omarchy-screensaver
      else pkgs.omarchy-screensaver;
    defaultText = "self.packages.\${system}.omarchy-screensaver";
    description = "Screensaver package providing the launch scripts and ttfx wrapper.";
  };

  windowClass = mkOption {
    type = types.str;
    default = "org.omarchy.screensaver";
    description = "Wayland app-id / window class used for fullscreen rules.";
  };

  compositor = mkOption {
    type = types.enum ["auto" "kwin" "hyprland"];
    default = "auto";
    description = ''
      Where to spawn fullscreen terminals.
      `auto` detects at launch and installs *both* the Plasma .desktop shortcut
      and Hyprland window rules, so one config works on KWin and Hyprland.
      `kwin` / `hyprland` install only that compositor's files.
    '';
  };

  terminal = mkOption {
    type = types.enum ["auto" "alacritty" "foot" "ghostty" "kitty"];
    default = "auto";
    description = "Terminal used to host the screensaver. `auto` picks from xdg-terminal-exec, then kitty/ghostty/foot/alacritty.";
  };

  configDir = mkOption {
    type = types.str;
    default = defaultConfigDir;
    defaultText = "\$XDG_CONFIG_HOME/omarchy-screensaver";
    description = "Directory for generated art and config.";
  };

  bind = mkOption {
    type = types.nullOr types.str;
    default = "Meta+Esc";
    example = "Meta+Esc";
    description = "Plasma `X-KDE-Shortcuts` value that force-starts the screensaver. Set null to skip the .desktop shortcut.";
  };

  art = {
    text = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = "Inline ASCII/Unicode art. Used when `image` and `file` are unset.";
    };
    file = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a pre-rendered ASCII art file.";
    };
    image = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "PNG or SVG converted to ASCII at build time via ImageMagick (braille or block).";
    };
    width = mkOption {
      type = types.ints.positive;
      default = 80;
      description = "Max columns when converting `art.image`.";
    };
    height = mkOption {
      type = types.ints.positive;
      default = 26;
      description = "Max rows when converting `art.image`.";
    };
    mode = mkOption {
      type = types.enum ["braille" "block"];
      default = "braille";
      description = "Glyph style for image conversion. Braille is finer.";
    };
    threshold = mkOption {
      type = types.ints.between 0 100;
      default = 50;
      description = "Percent threshold for which pixels count as the logo.";
    };
    invert = mkOption {
      type = types.bool;
      default = false;
      description = "Treat light pixels as the logo (for light-on-dark source images).";
    };
    trim = mkOption {
      type = types.bool;
      default = true;
      description = "Trim surrounding empty background before converting.";
    };
  };

  effects = {
    mode = mkOption {
      type = types.enum ["random" "single"];
      default = "random";
      description = "Pick a random ttfx effect each cycle, or always run `effects.single`.";
    };
    single = mkOption {
      type = types.nullOr (types.enum (import ./effect-names.nix));
      default = null;
      description = "Effect used when `mode = \"single\"`.";
    };
    include = mkOption {
      type = types.listOf (types.enum (import ./effect-names.nix));
      default = [];
      description = "When random, only these effects (empty = all, minus exclude).";
    };
    exclude = mkOption {
      type = types.listOf (types.enum (import ./effect-names.nix));
      default = [];
      description = "Effects skipped by `--random-effect`.";
    };
  };

  ttfx = {
    frameRate = mkOption {
      type = types.ints.unsigned;
      default = 120;
      description = "ttfx frame rate. Omarchy uses 120.";
    };
    canvasWidth = mkOption {
      type = types.int;
      default = 0;
      description = "ttfx `--canvas-width`. 0 = terminal width.";
    };
    canvasHeight = mkOption {
      type = types.int;
      default = 0;
      description = "ttfx `--canvas-height`. 0 = terminal height.";
    };
    reuseCanvas = mkOption {
      type = types.bool;
      default = true;
      description = "Pass `--reuse-canvas` so cycles don't flash.";
    };
    anchorCanvas = mkOption {
      type = types.str;
      default = "c";
      description = "Canvas anchor (n/s/e/w/c and diagonals).";
    };
    anchorText = mkOption {
      type = types.str;
      default = "c";
      description = "Text anchor inside the canvas.";
    };
    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra args appended to ttfx.";
    };
  };

  appearance = {
    fontSize = mkOption {
      type = types.ints.positive;
      default = 18;
      description = "Terminal font size for the screensaver window.";
    };
    fontFamily = mkOption {
      type = types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Font family used in the foot screensaver config.";
    };
    background = mkOption {
      type = types.str;
      default = "000000";
      description = "Background hex without or with leading #.";
    };
    foreground = mkOption {
      type = types.str;
      default = "ffffff";
      description = "Foreground hex without or with leading #.";
    };
    hideCursor = mkOption {
      type = types.bool;
      default = true;
      description = "Hide the cursor while the screensaver is up (ANSI, plus hyprctl on Hyprland).";
    };
    noctalia = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Follow the live Noctalia v5 palette. Writes user templates under
          `theme.templates.user.omarchy_screensaver_*` in
          `~/.config/noctalia/zz-omarchy-screensaver.toml` and template sources
          in `~/.config/omarchy-screensaver/templates/`. Switching a Hjem/Noctalia
          theme re-renders the screensaver terminal colors. Disable to bake
          `appearance.background` / `foreground` at build time instead.
        '';
      };
      background = mkOption {
        type = types.strMatching "[a-z][a-z0-9_]*";
        default = "terminal_background";
        example = "surface";
        description = ''
          Noctalia color token for the terminal background
          (`{{ colors.<token>.default.hex }}`).
          Common: `terminal_background`, `surface`, `background`.
        '';
      };
      foreground = mkOption {
        type = types.strMatching "[a-z][a-z0-9_]*";
        default = "terminal_foreground";
        example = "primary";
        description = ''
          Noctalia color token for the ASCII art.
          Common: `terminal_foreground`, `on_surface`, `primary`, `on_background`.
        '';
      };
    };
  };

  idle = {
    enable = mkEnableOption "Idle listeners that launch the screensaver (and optional lock)" // {default = true;};
    backend = mkOption {
      type = types.enum ["noctalia" "hypridle" "none"];
      default = "noctalia";
      description = ''
        `noctalia`: drop-in `~/.config/noctalia/zz-omarchy-screensaver.toml` for Noctalia v5
        (`action = "command"`). `hypridle`: append listeners via Home Manager's hypridle module.
        `none`: you wire idle yourself. Do not run Noctalia idle and hypridle at once — they would both fire.
      '';
    };
    timeout = mkOption {
      type = types.ints.positive;
      default = 150;
      description = "Seconds after idle before the screensaver launches. Counted from idle start.";
    };
    lockTimeout = mkOption {
      type = types.nullOr types.ints.positive;
      default = 300;
      description = "Seconds after idle before lock. Null disables the lock listener.";
    };
    lockCommand = mkOption {
      type = types.str;
      default = "loginctl lock-session";
      description = "Command run at lockTimeout when `idle.backend = \"hypridle\"`. Noctalia uses its native lock action.";
    };
    manageLock = mkOption {
      type = types.bool;
      default = true;
      description = "Also declare the lock behavior (Noctalia native lock, or a hypridle lock listener).";
    };
    writeBehaviorOrder = mkOption {
      type = types.bool;
      default = true;
      description = "Write Noctalia `idle.behavior_order` so screensaver runs before lock. Disable if you own that list.";
    };
    preActionFade = mkOption {
      type = types.nullOr types.number;
      default = null;
      description = "Noctalia `pre_action_fade_seconds`. Null leaves your existing fade setting.";
    };
  };

  kwin = {
    desktopShortcut = mkOption {
      type = types.bool;
      default = true;
      description = "Install a Plasma .desktop with X-KDE-Shortcuts from `bind` (Meta+Esc by default).";
    };
  };

  hyprland = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install Hyprland window rules and bind. Implied when compositor is `hyprland` or `auto`.";
    };
    bind = mkOption {
      type = types.nullOr types.str;
      default = "SUPER, Escape";
      example = "SUPER, Escape";
      description = "Hyprland bind prefix (without `exec`) that force-starts the screensaver. Set null to skip.";
    };
    ruleSyntax = mkOption {
      type = types.enum ["new" "legacy"];
      default = "new";
      description = "`new` is Hyprland 0.53+ (`windowrule = match:class …`). `legacy` emits windowrulev2.";
    };
    stayFocused = mkOption {
      type = types.bool;
      default = false;
      description = "Keep the screensaver focused (can fight bars/panels).";
    };
    animation = mkOption {
      type = types.str;
      default = "slide";
      description = "Hyprland animation for the screensaver window. Use `none` to disable.";
    };
    injectExtraConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Append rules to wayland.windowManager.hyprland.extraConfig when that Home Manager module is on.";
    };
  };
}
