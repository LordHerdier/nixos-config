# pkgs/st-wl
#
# st-wl (https://github.com/marchaesen/st-wl), the Wayland-native flexipatch
# build of st, with this repo's config.h and patches.h -- the same shape as
# pkgs/dwl. Used as the terminal for the dwl session.
#
# CONFIG. ./config.h and ./patches.h replace upstream's config.def.h and
# patches.def.h at build time. After a version bump, diff them against the
# new defaults and port new options across. Note that flexipatch also gates
# Makefile-level libraries (sixel/kitty graphics need imlib2, ligatures need
# harfbuzz) in config.mk, so a patch flipped on in patches.h may need a
# buildInputs / config.mk change here too.
#
# COLOURS ARE PARAMETERS (`colours`, attrs of #rrggbb), passed as -DCOL_* string-literal flags
# (config.h keeps matching fallbacks so it stays valid C). Unlike dwl they are
# fixed at build time; st-wl has no runtime palette file, so a theme change
# means a rebuild. Defaults are the OneShot palette.
#
# FONT. st-wl's default lives in wl.c rather than config.h, so postPatch
# rewrites it to kitty's font. Override at runtime with -f.
#
# ADDING A PATCH. Anything beyond flexipatch's own set: drop a `.patch` file
# in ./patches (applied in filename order, before config.h/patches.h are
# copied over the defaults).

{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  wayland-scanner,
  ncurses,
  wayland,
  wayland-protocols,
  fontconfig,
  freetype,
  libxkbcommon,
  pixman,
  imlib2,
  libx11,
  zlib,
  font ? "CaskaydiaCove Nerd Font:antialias=true:hintstyle=hintfull",
  # Overrides on top of the OneShot defaults below. One attrset rather than
  # one argument per colour: callPackage would fill bare `red`, `blue`, ...
  # arguments with the nixpkgs packages of those names.
  colours ? { },
}:

let
  c = {
    bg = "#000000";
    fg = "#cbb8ff";
    cursor = "#cbb8ff";
    cursorRev = "#4a3d66";
    black = "#000000";
    red = "#9664ff";
    green = "#9664ff";
    yellow = "#9664ff";
    blue = "#9664ff";
    magenta = "#9664ff";
    cyan = "#9664ff";
    white = "#cbb8ff";
    brightBlack = "#4a3d66";
    brightRed = "#cbb8ff";
    brightGreen = "#cbb8ff";
    brightYellow = "#cbb8ff";
    brightBlue = "#cbb8ff";
    brightMagenta = "#cbb8ff";
    brightCyan = "#cbb8ff";
    brightWhite = "#cbb8ff";
  }
  // colours;

  # "#rrggbb" -> -DCOL_X="#rrggbb". NIX_CFLAGS_COMPILE is split on
  # whitespace, not shell-parsed, so the quotes reach the compiler as-is.
  define = name: hex: "-DCOL_${name}=\"${hex}\"";
in
stdenv.mkDerivation {
  pname = "st-wl";
  version = "0.9.3-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "marchaesen";
    repo = "st-wl";
    rev = "86505348b5ebf1532229e201e5d782b8ea92266c";
    hash = "sha256-6ooB/qJQkTIMwtZL4fENtXlxn25Z0I6TJMdwyJcJJcw=";
  };

  patches =
    let
      dir = ./patches;
    in
    lib.optionals (builtins.pathExists dir) (
      map (name: dir + "/${name}") (
        builtins.filter (name: builtins.match ".*\\.patch" name != null) (
          builtins.attrNames (builtins.readDir dir)
        )
      )
    );

  postPatch = ''
    cp ${./config.h} config.def.h
    cp ${./patches.h} patches.def.h
    substituteInPlace wl.c \
      --replace-fail 'static char *font = "JetBrainsMono Nerd Font:antialias=true:hintstyle=hintfull";' \
                     'static char *font = "${font}";'
    # `tic -sx` would write to $HOME/.terminfo; install it into $out instead.
    substituteInPlace Makefile \
      --replace-fail 'tic -sx st.info' 'mkdir -p $(DESTDIR)$(PREFIX)/share/terminfo && tic -sx -o $(DESTDIR)$(PREFIX)/share/terminfo st.info'
  '';

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    ncurses
  ];

  buildInputs = [
    wayland
    wayland-protocols
    fontconfig
    freetype
    libxkbcommon
    pixman
    imlib2
    libx11
    zlib
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    (define "BG" c.bg)
    (define "FG" c.fg)
    (define "CURSOR" c.cursor)
    (define "CURSOR_REV" c.cursorRev)
    (define "BLACK" c.black)
    (define "RED" c.red)
    (define "GREEN" c.green)
    (define "YELLOW" c.yellow)
    (define "BLUE" c.blue)
    (define "MAGENTA" c.magenta)
    (define "CYAN" c.cyan)
    (define "WHITE" c.white)
    (define "BRIGHT_BLACK" c.brightBlack)
    (define "BRIGHT_RED" c.brightRed)
    (define "BRIGHT_GREEN" c.brightGreen)
    (define "BRIGHT_YELLOW" c.brightYellow)
    (define "BRIGHT_BLUE" c.brightBlue)
    (define "BRIGHT_MAGENTA" c.brightMagenta)
    (define "BRIGHT_CYAN" c.brightCyan)
    (define "BRIGHT_WHITE" c.brightWhite)
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  meta = {
    description = "Wayland-native flexipatch build of st";
    homepage = "https://github.com/marchaesen/st-wl";
    license = lib.licenses.mit;
    mainProgram = "st-wl";
    platforms = lib.platforms.linux;
  };
}
