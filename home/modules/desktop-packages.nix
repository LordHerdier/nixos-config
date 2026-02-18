# home/modules/desktop-packages.nix

{ pkgs, lib, isWsl, ... }:

{
  home.packages = (with pkgs; [
    firefox
    audacity
    gimp
    nautilus
    xfce.thunar
    tailscale
    mpvpaper
    hyprpaper
  ]);
}

