# home/modules/desktop-packages.nix

{ pkgs, ... }:

{
  home.packages = (
    with pkgs;
    [
      audacity
      # bitwarden-desktop
      proton-vpn
      discord
      legcord
      firefox
      fladder
      hyprcursor
      gimp
      gnome-keyring
      libreoffice
      moonlight-qt
      nautilus
      mpvpaper
      remmina
      spotify
      tailscale
      thunar
      tsukimi
      winboat
    ]
  );
}
