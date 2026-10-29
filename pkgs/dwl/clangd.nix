# pkgs/dwl/clangd.nix
#
# A .clangd for editing ./config.h with working LSP.
#
# config.h has no #includes of its own: dwl.c pastes it in after the includes,
# typedefs and prototypes it needs (`#include "config.h"`), so on its own
# clangd sees Rule, Layout, Key, tile, WLR_ERROR... as undefined. This builds
# the missing context: dwl.c cut off at that include line becomes a preamble
# header, alongside the generated *-protocol.h headers and the pkg-config
# include flags dwl's Makefile would use.
#
# Built from the patched dwl source, so patches in ./patches that touch dwl.c
# are reflected. Install the result with `nix run .#dwl-clangd`, which writes
# it to pkgs/dwl/.clangd (gitignored: it holds store paths).

{
  lib,
  stdenv,
  dwl,
  writeText,
}:

stdenv.mkDerivation {
  pname = "dwl-clangd";
  inherit (dwl) version src patches;

  # Same inputs dwl itself builds with: wlroots, wayland, xkbcommon, libinput,
  # xcb, wayland-protocols, plus wayland-scanner and pkg-config.
  inherit (dwl) buildInputs nativeBuildInputs;

  dontConfigure = true;
  dontInstall = true;

  buildPhase = ''
    runHook preBuild

    make $(sed -n 's/^\([a-z0-9-]*-protocol\.h\):.*/\1/p' Makefile)

    mkdir -p $out/include
    cp client.h ime.h util.h *-protocol.h $out/include/
    sed '/^#include "config.h"/,$d' dwl.c > $out/include/dwl-preamble.h

    wlr=$(sed -n 's/^WLR_INCS.*--cflags \(wlroots[^`]*\)`.*/\1/p' config.mk)
    cflags=$(pkg-config --cflags wayland-server xkbcommon libinput xcb xcb-icccm "$wlr")

    {
      echo "CompileFlags:"
      echo "  Add:"
      for flag in -xc -include $out/include/dwl-preamble.h -I$out/include \
          -DWLR_USE_UNSTABLE -D_POSIX_C_SOURCE=200809L -DXWAYLAND \
          '-DVERSION="${dwl.version}"' $cflags \
          -Wno-undefined-internal -Wno-unused-function; do
        printf '    - "%s"\n' "''${flag//\"/\\\"}"
      done
    } > $out/clangd.yaml

    runHook postBuild
  '';
}
