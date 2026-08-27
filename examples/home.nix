# Drop into your Home Manager user module, e.g. hosts/vanessa/home.nix
# after importing the flake module:
#
#   home-manager.sharedModules = [
#     inputs.omarchy-screensaver.homeManagerModules.default
#   ];
{
  programs.omarchyScreensaver = {
    enable = true;

    # kitty | ghostty | foot | alacritty | auto
    terminal = "kitty";

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
      background = "000000";
      foreground = "ffffff";
    };

    idle = {
      enable = true;
      timeout = 150; # seconds since idle began
      lockTimeout = 300;
      lockCommand = "loginctl lock-session";
      # set false if you already own services.hypridle.settings.listener
      manageHypridle = true;
    };

    hyprland = {
      enable = true;
      ruleSyntax = "new"; # "legacy" for Hyprland < 0.53
    };

    bind = "SUPER, Escape";
  };
}
