{
  lib,
  stdenvNoCC,
  makeWrapper,
  ttfx,
  jq,
  socat,
  imagemagick,
  gawk,
  coreutils,
  gnused,
  gnugrep,
  procps,
  util-linux,
  libnotify,
}:
stdenvNoCC.mkDerivation {
  pname = "omarchy-screensaver";
  version = "1.1.0";

  src = ../..;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/omarchy-screensaver

    cp scripts/omarchy-screensaver $out/bin/
    cp scripts/omarchy-screensaver-launch $out/bin/
    cp scripts/omarchy-screensaver-toggle $out/bin/
    cp scripts/omarchy-screensaver-ascii $out/bin/
    chmod +x $out/bin/*

    cp -r share/art $out/share/omarchy-screensaver/
    cp -r share/terminals $out/share/omarchy-screensaver/

    wrapProgram $out/bin/omarchy-screensaver \
      --prefix PATH : ${lib.makeBinPath [ttfx jq procps util-linux coreutils gnugrep gnused]} \
      --set-default SHARE_DIR $out/share/omarchy-screensaver

    wrapProgram $out/bin/omarchy-screensaver-launch \
      --prefix PATH : ${lib.makeBinPath [ttfx jq socat procps coreutils gnugrep gnused libnotify]} \
      --set-default SHARE_DIR $out/share/omarchy-screensaver \
      --set-default SCREENSAVER_BIN $out/bin/omarchy-screensaver

    wrapProgram $out/bin/omarchy-screensaver-toggle \
      --prefix PATH : ${lib.makeBinPath [coreutils libnotify]}

    wrapProgram $out/bin/omarchy-screensaver-ascii \
      --prefix PATH : ${lib.makeBinPath [imagemagick gawk coreutils gnused gnugrep]}

    runHook postInstall
  '';

  meta = {
    description = "Omarchy ASCII screensaver for KWin + Noctalia (Hyprland optional), packaged for NixOS / Hjem";
    homepage = "https://github.com/luxus/omarchy-screensaver-nix";
    license = lib.licenses.mit;
    mainProgram = "omarchy-screensaver-launch";
    platforms = lib.platforms.linux;
  };
}
