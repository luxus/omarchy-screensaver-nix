# Home Manager variant. Prefer examples/hjem.nix if you use Hjem / Hjem Rum.
#
#   home-manager.sharedModules = [
#     inputs.omarchy-screensaver.homeManagerModules.default
#   ];
{
  programs.omarchyScreensaver = {
    enable = true;
    compositor = "auto";
    terminal = "kitty";

    art = {
      image = ./logo.png;
      width = 80;
      height = 26;
      mode = "braille";
      threshold = 50;
    };

    effects = {
      mode = "random";
      exclude = ["bouncyballs"];
    };

    idle = {
      backend = "noctalia";
      timeout = 150;
      lockTimeout = 300;
    };

    appearance.noctalia.enable = true;
    appearance.noctalia.foreground = "terminal_foreground";

    bind = "Meta+Esc";
    hyprland.bind = "SUPER, Escape";
  };
}
