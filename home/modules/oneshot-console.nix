# home/modules/oneshot-console.nix
#
# GNOME Console (kgx) in the OneShot palette. kgx itself comes from
# GNOME (modules/profiles/desktop-gnome.nix); this only configures it.
#
# Its chrome is libadwaita, styled by oneshot-gtk.nix. The terminal grid
# isn't: kgx sets VTE colors programmatically, so no CSS reaches the 16
# ANSI slots.
#
# kgx 49+ "liveries" are named color schemes; custom ones live in two
# undocumented org.gnome.Console keys:
#
#   custom-liveries  a{sv}  uuid -> livery
#   livery           s      which uuid to use
#
# A livery is a vardict { uuid: s, name: s, night: palette, day: palette }
# (`day` optional, falls back to night; src/kgx-livery.c). A palette is
# { foreground: (ddd), background: (ddd), colours: a(ddd), transparency: d }
# with 0.0-1.0 components; transparency is left at its 0.0 default.
#
# NEEDS THE PATCHED kgx in pkgs/gnome-console: stock Console 50.0 drops
# every custom livery (wrong format string), silently.
#
# The GVariant type annotations matter: `dconf load` parses untyped, and
# an unannotated tuple comes back as the wrong type, which kgx silently
# skips. lib.hm.gvariant's mkTuple/mkArray emit them.

{ config, lib, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.my.oneshot-console;

  t = config.my.theme.palettes.${cfg.palette};
  p = t.palette;

  gv = lib.hm.gvariant;

  # Arbitrary but fixed, so re-skinning updates the livery in place.
  uuid = "bcfca44a-341b-417f-b880-5dc50b74eedf";

  # "#cbb8ff" -> @(ddd) (0.796078, 0.721569, 1.000000)
  rgb =
    hex:
    let
      c = config.my.theme.lib.hexToRgb hex;
      chan = v: gv.mkDouble (v / 255.0);
    in
    gv.mkTuple [
      (chan c.r)
      (chan c.g)
      (chan c.b)
    ];

  entry =
    key: value:
    gv.mkDictionaryEntry [
      key
      (gv.mkVariant value)
    ];

  nightPalette = gv.mkArray "{sv}" [
    (entry "foreground" (rgb p.fg))
    (entry "background" (rgb p.bg))
    (entry "colours" (
      gv.mkArray "(ddd)" (
        map rgb [
          p.black
          p.red
          p.green
          p.yellow
          p.blue
          p.magenta
          p.cyan
          p.white
          p.brightBlack
          p.brightRed
          p.brightGreen
          p.brightYellow
          p.brightBlue
          p.brightMagenta
          p.brightCyan
          p.brightWhite
        ]
      )
    ))
  ];

  livery = gv.mkArray "{sv}" [
    (entry "uuid" uuid)
    (entry "name" "Oneshot")
    (entry "night" nightPalette)
  ];
in
{
  options.my.oneshot-console = {
    palette = mkOption {
      type = types.enum (lib.attrNames config.my.theme.palettes);
      # Pinned to match the window: the oneshot palette is one purple, so
      # colored output is monochrome by design (kitty follows
      # my.theme.default). Point elsewhere for a readable grid.
      default = "oneshot";
      description = "Which my.theme palette GNOME Console's livery is built from.";
    };
  };

  config = {
    dconf.settings."org/gnome/Console" = {
      custom-liveries = gv.mkArray "{sv}" [ (entry uuid livery) ];
      livery = uuid;

      # The schema default, pinned so the in-app switcher can't leave
      # Console in light mode (the stylesheet has no light variant) past
      # the next activation.
      theme = "night";
    };
  };
}
