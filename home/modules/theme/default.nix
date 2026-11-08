# home/modules/theme/default.nix
#
# `my.theme` -- one place that owns the colors, so an app module says
# "the accent" instead of "#7fb4ca".
#
# SCOPE. Terminal/editor/TUI stack and the GTK theme, not the Hyprland
# desktop: noctalia derives those colors from the wallpaper at runtime.
# Two exceptions noctalia can't reach: hyprlock's cold-start fallback
# (hyprland/hyprlock-colors.nix) and the window borders
# (hyprland/40-design.nix).
#
# `my.theme.palettes.<name>` is a resolved theme:
#
#   .palette   the 16 ANSI colors plus bg/fg, lowercase #rrggbb
#   .roles     semantic slots, derived from the palette unless the
#              palette overrides them
#   .name      upstream theme name, for apps that select by string
#              (spotify-player's theme=, BAT_THEME, ...)
#   .polarity  "dark" | "light"
#
# Each app reads `my.theme.default` unless it pins its own palette
# (my.kitty.palette, my.nvim.palette).

{ config, lib, ... }:

let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;

  themeLib = import ./lib.nix { inherit lib; };
  cfg = config.my.theme;
in
{
  imports = [ ./runtime.nix ];

  # dwl (modules/features/dwl) keeps its own runtime colours; hand it the
  # palette through its switcher, which only exists on dwl hosts. wal has
  # no named palette, so dwl gets the dwl-colors fragment file instead.
  config.my.theme.fragments.dwl.reload = ''
    if command -v dwl-theme >/dev/null; then
      if [ "''${THEME_NAME:-}" = wal ]; then
        dwl-theme file "${config.my.theme.runtime.active}/dwl-colors"
      else
        dwl-theme "''${THEME_NAME:-default}"
      fi
    fi
  '';

  options.my.theme = {
    default = mkOption {
      type = types.enum (lib.attrNames cfg.palettes);
      default = "kanagawa";
      example = "catppuccin-mocha";
      description = ''
        Name of the palette apps use unless they override it. An app
        overrides it through its own option, e.g. `my.kitty.palette`.
      '';
    };

    palettes = mkOption {
      # Loosely typed on purpose: mkTheme already asserts on missing or
      # misspelled palette keys, so a submodule would only restate them.
      type = types.attrsOf types.attrs;
      default = mapAttrs (_: themeLib.mkTheme) (import ./palettes);
      defaultText = "all palettes under home/modules/theme/palettes";
      description = ''
        Registry of resolved themes, keyed by name. A host can add one by
        merging in `{ my.theme.palettes.foo = <resolved theme>; }`, but
        the usual way to add a palette is a file under palettes/.
      '';
    };

    active = mkOption {
      type = types.attrs;
      readOnly = true;
      default = cfg.palettes.${cfg.default};
      defaultText = "my.theme.palettes.\${my.theme.default}";
      description = "Shorthand for the default palette, resolved.";
    };

    lib = mkOption {
      type = types.attrs;
      readOnly = true;
      default = themeLib;
      defaultText = "home/modules/theme/lib.nix";
      description = ''
        Color format helpers: noHash, hexToRgb, rgbaHex, rgbaCsv,
        normalize, fzfColors. Every app wants hex in a different
        encoding, and that conversion belongs in one place.
      '';
    };
  };
}
