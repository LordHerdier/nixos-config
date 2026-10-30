# home/hosts/Index.nix

{ lib, ... }:
{
  imports = [
    ../profiles/desktop-hyprland.nix
    ../modules/easyeffects.nix
    ../modules/easyeffects-presets.nix
  ];

  my.theme.default = lib.mkForce "oneshot";

  my.easyeffects.enable = true;
  my.easyeffects.presets.enable = true;
}
