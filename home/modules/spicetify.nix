# home/modules/spicetify.nix
#
# The Spotify desktop client is a bundled Chromium app: it ignores the
# GTK/Qt theme entirely, so the only way to color it is to patch its
# `xpui` bundle. spicetify-nix does that at build time and hands back a
# patched `spotify` derivation, which is the only route that works here
# -- plain `spicetify apply` rewrites files inside the installed client,
# and the store is read-only.
#
# SCOPE: colors, nothing else. The upstream `theme` option stays at
# spicetify's own `default`, which is a bare color.ini with no layout or
# CSS changes, and `customColorScheme` merges a [custom] section into it
# built from my.theme. Swapping in a real theme later is one line --
#
#   programs.spicetify.theme =
#     inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.themes.sleek;
#
# -- and the colors below keep applying, because they are merged into
# whichever theme's color.ini is in play.
#
# VERSION COUPLING worth knowing before a flake update: the patched
# build records the Spotify version it was built against, so the
# spicetify-nix input and nixpkgs have to move roughly together. A
# mismatch shows up as a blank or broken client window at runtime, not
# as an eval failure.

{
  config,
  lib,
  inputs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.my.spicetify;

  theme = config.my.theme.palettes.${cfg.palette};
  p = theme.palette;
  r = theme.roles;

  # color.ini wants bare hex -- `#` in a value makes spicetify drop it.
  inherit (config.my.theme.lib) noHash;
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  options.my.spicetify = {
    enable = mkEnableOption "Spotify patched with spicetify, colored from my.theme";

    palette = mkOption {
      type = types.enum (lib.attrNames config.my.theme.palettes);
      default = config.my.theme.default;
      defaultText = "config.my.theme.default";
      description = ''
        Which my.theme palette Spotify draws its colors from. Follows the
        system palette; set it to pin Spotify to a different one.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;

      # Setting customColorScheme flips colorScheme to "custom" on its
      # own, so that option is deliberately left alone.
      customColorScheme = {
        text = noHash p.fg;
        subtext = noHash r.muted;

        main = noHash p.bg;
        sidebar = noHash r.surface;
        player = noHash r.surface;
        card = noHash r.surfaceAlt;
        shadow = noHash p.bg;

        # The now-playing row and the progress/volume bars, i.e. the two
        # places Spotify normally spends its green.
        selected-row = noHash r.accent;
        button = noHash r.accent;
        button-active = noHash r.accent;
        button-disabled = noHash r.borderInactive;
        tab-active = noHash r.accent;

        notification = noHash r.surfaceAlt;
        notification-error = noHash r.error;
        misc = noHash r.surfaceAlt;
      };
    };
  };
}
