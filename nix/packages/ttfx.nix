{
  lib,
  rustPlatform,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "ttfx";
  version = "0.3.2";
  inherit src;

  cargoLock.lockFile = "${src}/Cargo.lock";

  doCheck = false;

  meta = {
    description = "Terminal text effects — a Rust port of terminaltexteffects (TTE)";
    homepage = "https://github.com/omacom-io/ttfx";
    license = lib.licenses.mit;
    mainProgram = "ttfx";
    platforms = lib.platforms.linux;
  };
}
