# modules/common/fonts.nix

{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    terminus_font_ttf
  ];
}
