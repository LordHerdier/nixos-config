# home/hosts/Index.nix

{
  imports = [
    ../profiles/desktop-hyprland.nix
    ../modules/easyeffects.nix
  ];

  my.easyeffects.enable = true;
}
