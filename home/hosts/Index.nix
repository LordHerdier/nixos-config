# home/hosts/Index.nix

{ config, lib, ... }:
{
  imports = [
    ../profiles/desktop-hyprland.nix
    ../modules/easyeffects.nix
    ../modules/easyeffects-presets.nix
  ];

  my.theme.default = lib.mkForce "halloween";

  my.easyeffects.enable = true;
  my.easyeffects.presets.enable = true;

  # Main GPG key for Index (uploaded to GitHub). This file is also imported by
  # rivian (parts/hosts.nix), who doesn't have the key, hence the guard.
  programs.git.signing = lib.mkIf (config.home.username == "charlotte") {
    key = "1C58EC2D89AD092C";
    signByDefault = true;
  };
}
