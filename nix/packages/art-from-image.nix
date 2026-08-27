{
  lib,
  runCommand,
  imagemagick,
  gawk,
  coreutils,
  omarchy-screensaver,
  image,
  width ? 80,
  height ? 26,
  mode ? "braille",
  threshold ? 50,
  invert ? false,
  trim ? true,
}:
runCommand "omarchy-screensaver-art.txt" {
  nativeBuildInputs = [imagemagick gawk coreutils omarchy-screensaver];
  inherit image;
  passAsFile = [];
} ''
  extra=()
  ${lib.optionalString invert "extra+=(--invert)"}
  ${lib.optionalString (!trim) "extra+=(--no-trim)"}
  omarchy-screensaver-ascii "$image" "$out" \
    --width ${toString width} \
    --height ${toString height} \
    --mode ${mode} \
    --threshold ${toString threshold} \
    "''${extra[@]}"
''
