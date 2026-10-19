# home/modules/oneshot-console.nix
#
# GNOME Console (kgx) in the OneShot palette. Sibling of oneshot-gtk.nix,
# oneshot-icons.nix and oneshot-cursors.nix; kgx itself comes from GNOME
# (modules/profiles/desktop-gnome.nix), so this module only configures it.
#
# Console's *chrome* needs nothing from here -- it is a libadwaita app, so
# oneshot-gtk.nix's user stylesheet reaches its headerbar, tabs, popovers
# and empty state exactly like it reaches Nautilus. What no stylesheet can
# reach is the terminal grid, because kgx hands those colors to VTE
# programmatically (vte_terminal_set_colors) rather than through CSS. No
# provider, at any priority, gets a say in the 16 ANSI slots. So without
# the dconf below you get a black-and-purple window around GNOME's stock
# grey-blue terminal.
#
# WHERE THOSE COLORS LIVE. kgx 49 replaced its three hardcoded themes with
# "liveries" -- named color schemes, three built in (uuids for GNOME,
# Linux and XTerm) plus any number of custom ones in gsettings. The schema
# (org.gnome.Console) exposes them as two keys and documents neither:
#
#   custom-liveries  a{sv}  uuid -> livery
#   livery           s      which uuid to use
#
# A livery is a vardict of { uuid: s, name: s, night: palette,
# day: palette }; `night` is required, `day` optional, and a livery with
# no `day` is used for both (src/kgx-livery.c, kgx_livery_resolve). A
# palette is a vardict of { foreground: (ddd), background: (ddd),
# colours: a(ddd), transparency: d } -- components are 0.0-1.0 doubles,
# `colours` is the 16 ANSI slots in the usual order, and `transparency` is
# left off here because its default is 0.0, which is the opaque black the
# rice wants. (That also makes Console's own transparency toggle a no-op,
# which is the right outcome rather than a missing feature.)
#
# AND IT NEEDS A PATCHED kgx. Console 50.0 reads custom-liveries with a
# tuple format string against what is actually a dictionary entry, so the
# loop that loads them aborts on the first element and every custom
# livery is dropped -- all of this would be a silent no-op without
# pkgs/gnome-console, which fixes that in one character. Nothing here
# breaks on an unpatched Console; it just has no effect, which is exactly
# why it is worth writing down.
#
# The type annotations in the GVariant text are what make this work:
# `dconf load` parses each value with no expected type, so an unannotated
# `(0.0, 0.0, 0.0)` would come back as the wrong tuple type and kgx's
# g_variant_dict_lookup would quietly skip the key and fall back to white
# on near-black. lib.hm.gvariant's mkTuple/mkArray emit them; building the
# text by hand would not.

{ config, lib, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.my.oneshot-console;

  t = config.my.theme.palettes.${cfg.palette};
  p = t.palette;

  gv = lib.hm.gvariant;

  # Nothing identifies a livery but its uuid, so this one is arbitrary and
  # fixed: generated once, and stable from then on so that re-skinning
  # (pointing `palette` elsewhere) updates the existing livery in place
  # rather than orphaning it and leaving `livery` dangling.
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
      # Pinned to "oneshot" to match the window around it, with eyes open:
      # the oneshot palette collapses all six hues onto one purple, so
      # ls/grep/git color output in Console is monochrome by design. That
      # is the art-directed look, and kitty -- the terminal actually used
      # for work here -- follows my.theme.default instead. Point this at
      # another palette for a readable grid in a black-and-purple window.
      default = "oneshot";
      description = "Which my.theme palette GNOME Console's livery is built from.";
    };
  };

  config = {
    dconf.settings."org/gnome/Console" = {
      custom-liveries = gv.mkArray "{sv}" [ (entry uuid livery) ];
      livery = uuid;

      # Already the schema default, but Home Manager managing it is the
      # point: it also drives AdwStyleManager's color-scheme, and the
      # in-app theme switcher writes this same key. Pinning it means a
      # stray click there cannot leave Console in light mode against a
      # stylesheet that has no light variant. (As with GNOME Tweaks --
      # see ../profiles/desktop-gnome.nix -- the switcher still appears to
      # work until the next activation writes this back.)
      theme = "night";
    };
  };
}
