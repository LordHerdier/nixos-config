# home/modules/wofi.nix
#
# Launcher styling from `my.theme` (see home/modules/theme). Only the
# stylesheet and the drun defaults live here; the package is the system
# one from modules/profiles/desktop-hyprland.nix, which is what the dwl
# and Hyprland binds actually launch.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.my.wofi;

  theme = config.my.theme.palettes.${cfg.palette};
  p = theme.palette;
  r = theme.roles;

  follows = config.my.theme.follows cfg.palette;

  # The colours wofi.css uses, by the name of its @placeholder@.
  colours = t: {
    inherit (t.palette) bg fg;
    inherit (t.roles)
      accent
      border
      selectionBg
      selectionFg
      surface
      surfaceAlt
      ;
  };

  # Following the runtime palette: the stylesheet names GTK colours
  # (`@wofi_accent`) that the active palette's fragment defines. wofi reads
  # its style each time it opens, so a switch needs no reload.
  runtimeStyle =
    let
      names = lib.attrNames (colours theme);
    in
    pkgs.writeText "wofi.css" (
      ''
        @import url("file://${config.my.theme.runtime.active}/wofi.css");
      ''
      + builtins.replaceStrings (map (n: "@${n}@") names) (map (n: "@wofi_${n}") names) (
        builtins.readFile ./wofi.css
      )
    );
in
{
  options.my.wofi = {
    enable = mkEnableOption "my.theme styling for wofi";

    palette = mkOption {
      type = types.enum (lib.attrNames config.my.theme.palettes);
      default = config.my.theme.default;
      defaultText = "config.my.theme.default";
      description = ''
        Which my.theme palette wofi draws its colors from. Follows the
        system palette; set it to pin wofi to a different one.
      '';
    };
  };

  config = mkIf cfg.enable {
    my.theme.fragments.wofi = mkIf follows {
      file = "wofi.css";
      wal = true;
      render =
        t: lib.concatStrings (lib.mapAttrsToList (k: v: "@define-color wofi_${k} ${v};\n") (colours t));
    };

    programs.wofi = {
      enable = true;
      package = null;

      settings = {
        mode = "drun";
        allow_images = true;
        prompt = "Run";
        width = 480;
        lines = 8;
        location = "center";
        insensitive = true;
      };

      style = if follows then runtimeStyle else pkgs.replaceVars ./wofi.css (colours theme);
    };
  };
}
