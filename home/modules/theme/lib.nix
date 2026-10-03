# home/modules/theme/lib.nix
#
# Pure helpers behind `my.theme`. Deliberately takes only `lib`, no `pkgs`
# and no module-system `config`, so the palette files and the role
# derivation can also be imported directly from a derivation in pkgs/
# (which is what the GTK stylesheet substitution will need).
#
# Two layers, and the split is the whole point of this module:
#
#   palette  the 16 ANSI colors plus bg/fg. What a terminal, a TUI or a
#            colorscheme plugin wants, because those address colors by
#            index or by ANSI name.
#   roles    semantic slots -- accent, border, selection, ... What UI
#            chrome wants, because "the accent" is a job, not a hue.
#
# Collapsing the two is what makes this kind of refactor rot: an app that
# wants "the active border color" should not have to know that it happens
# to be the palette's blue in one theme and an off-palette mauve in
# another.

{ lib }:

let
  inherit (lib)
    attrNames
    concatMapStringsSep
    concatStringsSep
    mapAttrs
    stringToCharacters
    subtractLists
    toLower
    ;
  inherit (lib.strings) substring;

  hexDigit = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
  };

  # Every key a palette has to define. Enforced, so a typo in a palette
  # file fails at eval with a pointed message instead of silently handing
  # some consumer a null.
  paletteKeys = [
    "bg"
    "fg"
    "black"
    "red"
    "green"
    "yellow"
    "blue"
    "magenta"
    "cyan"
    "white"
    "brightBlack"
    "brightRed"
    "brightGreen"
    "brightYellow"
    "brightBlue"
    "brightMagenta"
    "brightCyan"
    "brightWhite"
  ];

  self = {
    inherit paletteKeys;

    # "#1F1F28" -> "1f1f28". Wanted by hyprlock (`rgb($foo)` over a
    # sourced variable), gtk-2.0 gtkrc and anything shell-ish.
    noHash =
      hex: toLower (if substring 0 1 hex == "#" then substring 1 (lib.stringLength hex - 1) hex else hex);

    # "#1f1f28" -> { r = 31; g = 31; b = 40; }
    hexToRgb =
      hex:
      let
        s = self.noHash hex;
        byte = i: 16 * hexDigit.${substring i 1 s} + hexDigit.${substring (i + 1) 1 s};
      in
      {
        r = byte 0;
        g = byte 2;
        b = byte 4;
      };

    # Hyprland's packed form: rgba(RRGGBBAA), alpha as a 0.0-1.0 float.
    rgbaHex =
      hex: alpha:
      let
        a = builtins.floor (alpha * 255.0 + 0.5);
        hi = builtins.div a 16;
        lo = a - (hi * 16);
        nibble = n: builtins.elemAt (stringToCharacters "0123456789abcdef") n;
      in
      "rgba(${self.noHash hex}${nibble hi}${nibble lo})";

    # Hyprland also accepts the comma form, and hyprlock wants it for
    # inner_color. rgba(31, 31, 40, 1.0)
    rgbaCsv =
      hex: alpha:
      let
        c = self.hexToRgb hex;
      in
      "rgba(${toString c.r}, ${toString c.g}, ${toString c.b}, ${toString alpha})";

    # Normalize to lowercase #rrggbb so the same color written two
    # different ways in two apps stops being two different strings.
    normalize = hex: "#${self.noHash hex}";

    # Role defaults, derived from the palette. Every one of these is
    # overridable per palette -- they are a sane starting point, not a
    # claim that e.g. the accent is always the blue.
    defaultRoles = p: {
      surface = p.black;
      surfaceAlt = p.brightBlack;
      muted = p.brightBlack;
      accent = p.blue;
      accentFg = p.black;
      border = p.blue;
      borderInactive = p.brightBlack;
      selectionBg = p.brightBlack;
      selectionFg = p.fg;
      cursor = p.fg;
      url = p.blue;
      success = p.green;
      warning = p.yellow;
      error = p.red;
    };

    # Turn a palette file into a resolved theme: palette normalized, roles
    # filled in from the defaults, name/polarity carried through.
    mkTheme =
      raw:
      let
        missing = subtractLists (attrNames raw.palette) paletteKeys;
        extra = subtractLists paletteKeys (attrNames raw.palette);
        palette = mapAttrs (_: self.normalize) raw.palette;
        roles = mapAttrs (_: self.normalize) (self.defaultRoles palette // (raw.roles or { }));
      in
      assert lib.assertMsg (missing == [ ]) (
        "theme palette '${raw.name}' is missing: ${concatStringsSep ", " missing}"
      );
      assert lib.assertMsg (extra == [ ]) (
        "theme palette '${raw.name}' has unknown keys (roles go under `roles`): "
        + concatStringsSep ", " extra
      );
      {
        inherit (raw) name;
        polarity = raw.polarity or "dark";
        inherit palette roles;
      };

    # fzf wants one flat --color= argument; building it from an attrset
    # keeps the ordering stable and the call sites readable.
    fzfColors = mapping: concatMapStringsSep "," (k: "${k}:${mapping.${k}}") (attrNames mapping);
  };
in
self
