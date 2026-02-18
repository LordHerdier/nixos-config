# hosts/Pine.nix

{
  imports = [
    ../modules/hyprland/default.nix
    ../modules/desktop-files.nix
    ../modules/desktop-packages.nix
  ];
}
