# home/modules/spicetify.nix
#
# Spotify ignores GTK/Qt themes, so it's colored by patching its `xpui`
# bundle; spicetify-nix does that at build time (`spicetify apply` can't
# touch the read-only store).
#
# Colors only: `theme` stays at spicetify's bare `default`, and
# `customColorScheme` merges a my.theme [custom] section into whichever
# theme's color.ini is in play, so a real theme is a one-line swap:
#
#   programs.spicetify.theme =
#     inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.themes.sleek;
#
# VERSION COUPLING: spicetify-nix and nixpkgs' Spotify must move roughly
# together; a mismatch shows as a blank/broken window at runtime, not an
# eval failure.

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

        # Where Spotify normally spends its green.
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
