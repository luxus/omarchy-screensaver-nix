{
  description = "Omarchy's ASCII screensaver, extracted as a NixOS + Home Manager module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ttfx = {
      url = "github:omacom-io/ttfx";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ttfx,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system:
        f (import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        }));
  in {
    overlays.default = final: prev: {
      ttfx = final.callPackage ./nix/packages/ttfx.nix {src = ttfx;};
      omarchy-screensaver = final.callPackage ./nix/packages/screensaver.nix {
        ttfx = final.ttfx;
      };
    };

    packages = forAllSystems (pkgs: rec {
      inherit (pkgs) ttfx omarchy-screensaver;
      default = omarchy-screensaver;
    });

    homeManagerModules.default = import ./nix/modules/home-manager.nix {inherit self;};
    homeManagerModules.omarchyScreensaver = self.homeManagerModules.default;

    nixosModules.default = import ./nix/modules/nixos.nix {inherit self;};
    nixosModules.omarchyScreensaver = self.nixosModules.default;

    formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
  };
}
