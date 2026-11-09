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

  # Index's GPG key (uploaded to GitHub). rivian imports this file too
  # (parts/hosts.nix) but doesn't have the key, hence the guard.
  programs.git.signing = lib.mkIf (config.home.username == "charlotte") {
    key = "1C58EC2D89AD092C";
    signByDefault = true;
  };
}
