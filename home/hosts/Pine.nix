# hosts/Pine.nix

{
  imports = [
    ../modules/hyprland/default.nix
    ../modules/desktop-files.nix
    ../modules/desktop-packages.nix
    ../modules/kitty.nix
    ../../modules/common/kmonad.nix
    ../modules/kmonad.nix
  ];

  my.kitty.enable = true;
}
