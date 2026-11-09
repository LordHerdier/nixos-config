# home/modules/theme/lib.nix
#
# Pure helpers behind `my.theme`. Takes only `lib` (no `pkgs`, no module
# `config`) so it can also be imported from outside the module system.
#
# Two layers, deliberately kept apart:
#
#   palette  the 16 ANSI colors plus bg/fg -- what terminals, TUIs and
#            colorscheme plugins address by index or ANSI name.
#   roles    semantic slots (accent, border, selection, ...) -- what UI
#            chrome wants. An app asking for "the active border" shouldn't
#            need to know it's blue in one theme and mauve in another.

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

    # Linear sRGB blend; `t` is how much of `b` to take. Crude, but it
    # only derives accentDim for palettes that don't name one.
    mix =
      a: b: t:
      let
        ca = self.hexToRgb a;
        cb = self.hexToRgb b;
        chan =
          x: y:
          let
            v = builtins.floor ((x * (1.0 - t)) + (y * t) + 0.5);
          in
          self.hexByte (
            if v < 0 then
              0
            else if v > 255 then
              255
            else
              v
          );
      in
      "#${chan ca.r cb.r}${chan ca.g cb.g}${chan ca.b cb.b}";

    # 0-255 -> two lowercase hex digits.
    hexByte =
      n:
      let
        digits = stringToCharacters "0123456789abcdef";
        hi = n / 16;
      in
      builtins.elemAt digits hi + builtins.elemAt digits (n - (hi * 16));

    # Normalize to lowercase #rrggbb so the same color written two
    # different ways in two apps stops being two different strings.
    normalize = hex: "#${self.noHash hex}";

    # Role defaults, derived from the palette; each is overridable per
    # palette via `roles`.
    defaultRoles =
      p:
      let
        accent = p.blue;
      in
      {
        inherit accent;
        surface = p.black;
        surfaceAlt = p.brightBlack;
        muted = p.brightBlack;
        accentFg = p.black;
        # No ANSI slot is "the accent, but quieter"; a palette that cares
        # should name it.
        accentDim = self.mix accent p.bg 0.5;
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

    # GNOME 47+ accent is a nine-value enum, not free-form hex, so map
    # onto the nearest one (libadwaita's src/stylesheet/_colors.scss
    # values; squared sRGB distance is fine, they're far apart in hue).
    gnomeAccents = {
      blue = "#3584e4";
      teal = "#2190a4";
      green = "#3a944a";
      yellow = "#c88800";
      orange = "#ed5b00";
      red = "#e62d42";
      pink = "#d56199";
      purple = "#9141ac";
      slate = "#6f8396";
    };

    nearestGnomeAccent =
      hex:
      let
        c = self.hexToRgb hex;
        dist =
          other:
          let
            o = self.hexToRgb other;
            dr = c.r - o.r;
            dg = c.g - o.g;
            db = c.b - o.b;
          in
          (dr * dr) + (dg * dg) + (db * db);
        best = lib.foldl' (
          acc: name:
          let
            d = dist self.gnomeAccents.${name};
          in
          if acc == null || d < acc.d then { inherit name d; } else acc
        ) null (attrNames self.gnomeAccents);
      in
      best.name;

    # fzf wants one flat --color= argument; building it from an attrset
    # keeps the ordering stable and the call sites readable.
    fzfColors = mapping: concatMapStringsSep "," (k: "${k}:${mapping.${k}}") (attrNames mapping);
  };
in
self
