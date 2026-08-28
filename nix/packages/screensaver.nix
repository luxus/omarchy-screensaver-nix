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
  kdePackages,
  xorg,
}:
stdenvNoCC.mkDerivation {
  pname = "omarchy-screensaver";
  version = "1.1.0";

  src = ../..;

  nativeBuildInputs = [
    makeWrapper
    imagemagick
    xorg.xcursorgen
  ];

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

    # Invisible pointer so GTK/Ghostty does not show the compositor cursor.
    mkdir -p $out/share/omarchy-screensaver/icons/omarchy-ss-blank/cursors
    magick -size 32x32 xc:none blank.png
    printf '32 0 0 blank.png\n' > blank.cursor
    xcursorgen blank.cursor $out/share/omarchy-screensaver/icons/omarchy-ss-blank/cursors/left_ptr
    for n in default pointer text xterm wait hand2 arrow sb_v_double_arrow sb_h_double_arrow; do
      ln -sf left_ptr $out/share/omarchy-screensaver/icons/omarchy-ss-blank/cursors/$n
    done
    printf '%s\n' '[Icon Theme]' 'Name=omarchy-ss-blank' 'Comment=Invisible cursor for the screensaver' 'Inherits=' \
      > $out/share/omarchy-screensaver/icons/omarchy-ss-blank/index.theme

    wrapProgram $out/bin/omarchy-screensaver \
      --prefix PATH : ${
        lib.makeBinPath [
          ttfx
          jq
          procps
          util-linux
          coreutils
          gnugrep
          gnused
        ]
      } \
      --set-default SHARE_DIR $out/share/omarchy-screensaver

    wrapProgram $out/bin/omarchy-screensaver-launch \
      --prefix PATH : ${
        lib.makeBinPath [
          ttfx
          jq
          socat
          procps
          coreutils
          gnugrep
          gnused
          libnotify
          kdePackages.qttools
          kdePackages.libkscreen
        ]
      } \
      --set-default SHARE_DIR $out/share/omarchy-screensaver \
      --set-default SCREENSAVER_BIN $out/bin/omarchy-screensaver

    wrapProgram $out/bin/omarchy-screensaver-toggle \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          libnotify
        ]
      }

    wrapProgram $out/bin/omarchy-screensaver-ascii \
      --prefix PATH : ${
        lib.makeBinPath [
          imagemagick
          gawk
          coreutils
          gnused
          gnugrep
        ]
      }

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
