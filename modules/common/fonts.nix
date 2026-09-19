# modules/common/fonts.nix

{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    terminus_font_ttf
  ];

  # Explicit so font rendering doesn't depend on whatever a desktop
  # environment's session daemon would otherwise push via GSettings/
  # XSettings (which nothing does under Hyprland). See
  # home/modules/font-rendering.nix for the GTK/Qt side of this.
  fonts.fontconfig = {
    antialias = true;
    hinting = {
      enable = true;
      style = "slight";
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    defaultFonts = {
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
      monospace = [ "CaskaydiaCove Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
