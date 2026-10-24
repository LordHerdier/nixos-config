# home/hosts/Index.nix

{
  imports = [
    ../profiles/desktop-hyprland.nix
    ../modules/easyeffects.nix
    ../modules/easyeffects-presets.nix
  ];

  my.easyeffects.enable = true;
  my.easyeffects.presets.enable = true;
}
