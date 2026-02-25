# home/profiles/desktop-hyprland.nix

{ ... }:

{
  imports = [
    ../modules/hyprland/default.nix
    ../modules/desktop-files.nix
    ../modules/desktop-packages.nix
    ../modules/kitty.nix
  ];

  my.kitty.enable = true;
}
