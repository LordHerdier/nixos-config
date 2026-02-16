# home/modules/desktop-packages.nix

{ pkgs, lib, isWsl, ... }:

{
  home.packages = (with pkgs; [
    firefox
  ]);
}

