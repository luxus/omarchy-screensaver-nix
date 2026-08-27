{self}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.programs.omarchyScreensaver;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.programs.omarchyScreensaver = {
    enable = mkEnableOption "Install the Omarchy screensaver package system-wide (session wiring still lives in the Hjem or Home Manager module)";

    package = mkOption {
      type = types.package;
      default =
        if self ? packages && self.packages ? ${system}
        then self.packages.${system}.omarchy-screensaver
        else pkgs.omarchy-screensaver;
      defaultText = "self.packages.\${system}.omarchy-screensaver";
      description = "Package to install into environment.systemPackages.";
    };
  };

  config = {
    nixpkgs.overlays = [self.overlays.default];
    environment.systemPackages = mkIf cfg.enable [cfg.package];
  };
}
