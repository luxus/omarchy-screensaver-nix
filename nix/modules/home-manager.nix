{self}: {
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  inherit (lib) mkIf mkDefault mkMerge mkAfter;

  cfg = config.programs.omarchyScreensaver;
  g = import ./lib.nix {
    inherit lib pkgs cfg;
    pkg = cfg.package;
  };

  hasHyprlandHM = options.wayland ? windowManager && options.wayland.windowManager ? hyprland;
  hasHypridle = options.services ? hypridle;
  hyprlandEnabled = hasHyprlandHM && config.wayland.windowManager.hyprland.enable;

  defaultConfigDir = "${config.xdg.configHome}/omarchy-screensaver";

  toConfigFile = files:
    lib.mapAttrs' (name: value: {
      name = name;
      value = value;
    })
    files;
in {
  options.programs.omarchyScreensaver = import ./options.nix {
    inherit lib pkgs self defaultConfigDir;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = g.assertions;
      home.packages = [cfg.package];
      xdg.configFile = toConfigFile g.configFiles;
      home.sessionVariables.OMARCHY_SCREENSAVER_CONFIG = "${cfg.configDir}/config";
    }
    (mkIf g.writeNoctalia {
      xdg.configFile = toConfigFile g.noctaliaFile;
    })
    (mkIf g.writeHypr {
      xdg.configFile = toConfigFile g.hyprFile;
    })
    (mkIf g.writeDesktop {
      xdg.dataFile."applications/omarchy-screensaver.desktop".text = g.desktopEntry;
    })
    (mkIf (g.writeHypr && cfg.hyprland.injectExtraConfig && hyprlandEnabled) {
      wayland.windowManager.hyprland.extraConfig = mkAfter ''
        source = ${config.xdg.configHome}/hypr/omarchy-screensaver.conf
      '';
    })
    (mkIf (g.writeHypridle && hasHypridle) {
      services.hypridle.enable = mkDefault true;
      services.hypridle.extraConfig = mkAfter g.hypridleSnippet;
    })
  ]);
}
