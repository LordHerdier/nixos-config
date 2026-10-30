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

      style = (
        pkgs.replaceVars ./wofi.css {
          inherit (p) bg fg;
          inherit (r)
            accent
            border
            selectionBg
            selectionFg
            surface
            surfaceAlt
            ;
        }
      );
    };
  };
}
