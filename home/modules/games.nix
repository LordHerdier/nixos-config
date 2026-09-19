# home/modules/games.nix

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    prismlauncher
    lutris

    # KSP Mod Tool
    ckan
  ];

}
