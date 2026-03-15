# home/modules/desktop-packages.nix

{ pkgs, ... }:

{
  home.packages = (
    with pkgs;
    [
      audacity
      discord
      firefox
      gamescope
      gimp
      hyprpaper
      moonlight-qt
      mpvpaper
      nautilus
      remmina
      spotify
      tailscale
      thunar
      tsukimi
    ]
  );
}
