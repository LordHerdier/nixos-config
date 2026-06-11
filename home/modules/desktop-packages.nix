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
      winboat
    ]
  );
}
