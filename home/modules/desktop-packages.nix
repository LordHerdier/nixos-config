# home/modules/desktop-packages.nix

{ pkgs, ... }:

{
  home.packages = (
    with pkgs;
    [
      audacity
      discord
      firefox
      gimp
      moonlight-qt
      nautilus
      mpvpaper
      remmina
      spotify
      tailscale
      thunar
      tsukimi
    ]
  );
}
