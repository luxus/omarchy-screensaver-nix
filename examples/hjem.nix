# Drop into hjem.users.<name> after:
#
#   hjem.extraModules = [
#     inputs.hjem-rum.hjemModules.default
#     inputs.omarchy-screensaver.hjemModules.default
#   ];
#
# rum.programs.omarchyScreensaver is an alias of programs.omarchyScreensaver.
{
  programs.omarchyScreensaver = {
    enable = true;
    compositor = "auto"; # kwin + hyprland files; launch detects the session
    terminal = "kitty"; # kitty | ghostty | foot | alacritty | auto

    # Inline ASCII, a .txt file, or a PNG/SVG converted at build time.
    # Priority: image > file > text > bundled Omarchy wordmark.
    art = {
      # text = ''
      #   hello
      # '';
      # file = ./screensaver.txt;
      image = ./logo.png;
      width = 80;
      height = 26;
      mode = "braille"; # or "block"
      threshold = 50;
      invert = false;
    };

    effects = {
      mode = "random"; # or "single"
      # single = "matrix";
      # include = [ "matrix" "rain" "decrypt" "beams" ];
      exclude = ["bouncyballs"];
    };

    ttfx.frameRate = 120;

    appearance = {
      fontSize = 18;
      # Follow the live Noctalia v5 palette (Hjem theme / wallpaper Material You).
      noctalia.enable = true;
      noctalia.background = "terminal_background";
      noctalia.foreground = "terminal_foreground"; # or "primary"
      # Fallback if you set noctalia.enable = false:
      # background = "000000";
      # foreground = "ffffff";
    };

    idle = {
      enable = true;
      backend = "noctalia"; # noctalia | hypridle | none
      timeout = 150; # seconds since idle began
      lockTimeout = 300; # native Noctalia lock; set null to skip
      manageLock = true;
      writeBehaviorOrder = true; # screensaver before lock
    };

    # Plasma .desktop X-KDE-Shortcuts *and* Hyprland bind (compositor = auto).
    bind = "Meta+Esc";
    hyprland.bind = "SUPER, Escape";
  };
}
