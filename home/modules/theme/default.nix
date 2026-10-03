# home/modules/theme/default.nix
#
# `my.theme` -- one place that owns the colors, so an app module says
# "the accent" instead of "#7fb4ca".
#
# SCOPE. This governs the terminal/editor/TUI stack and the GTK theme.
# It deliberately does NOT govern the Hyprland desktop: noctalia derives
# its colors from the wallpaper at runtime, and that is the source of
# truth there. The one exception is a cold start -- see
# home/modules/hyprland/hyprlock-colors.nix, which falls back to this
# palette only until noctalia has written its colors once.
#
# WHAT A CONSUMER READS. `my.theme.palettes.<name>` is a resolved theme:
#
#   .palette   the 16 ANSI colors plus bg/fg, lowercase #rrggbb
#   .roles     semantic slots, role defaults derived from the palette and
#              overridden where a palette has an opinion
#   .name      the upstream theme's name, for apps that select by string
#              (spotify-player's theme=, BAT_THEME, ...)
#   .polarity  "dark" | "light"
#
# WHICH palette a consumer gets is per-app, defaulting to
# `my.theme.default`. That indirection is not ceremony: kitty, neovim and
# tmux are currently on three different palettes, and keeping the choice
# nameable is what lets them be ported one at a time without changing how
# any of them look.

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
      # Loosely typed on purpose. A submodule here would mean restating
      # the 18 palette keys and 14 role keys in the type, in a module
      # that already validates them: mkTheme asserts on a missing or
      # misspelled key and names it. Palettes are data files, not
      # user-facing configuration.
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
