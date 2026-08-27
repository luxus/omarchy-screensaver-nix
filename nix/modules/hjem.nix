{self}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;

  cfg = config.programs.omarchyScreensaver;
  g = import ./lib.nix {
    inherit lib pkgs cfg;
    pkg = cfg.package;
  };

  defaultConfigDir = "${config.directory}/.config/omarchy-screensaver";
in {
  _class = "hjem";

  imports = [
    (lib.mkAliasOptionModule ["rum" "programs" "omarchyScreensaver"] ["programs" "omarchyScreensaver"])
  ];

  options.programs.omarchyScreensaver = import ./options.nix {
    inherit lib pkgs self defaultConfigDir;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = g.assertions;
      packages = [cfg.package];
      xdg.config.files = g.configFiles;
    }
    (mkIf g.writeNoctalia {
      xdg.config.files = g.noctaliaFile;
    })
    (mkIf g.writeHypr {
      xdg.config.files = g.hyprFile;
    })
    (mkIf g.writeDesktop {
      xdg.data.files."applications/omarchy-screensaver.desktop".text = g.desktopEntry;
    })
  ]);
}
