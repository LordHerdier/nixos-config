# home/modules/desktop-packages.nix

{ pkgs, ... }:

{
  home.packages = (
    with pkgs;
    [
      audacity
      bitwarden-desktop
      discord
      firefox
      fladder
      hyprcursor
      gimp
      gnome-keyring
      moonlight-qt
      nautilus
      mpv
      mpvpaper
      remmina
      spotify
      tailscale
      thunar
      tsukimi
    ]
  );
}
