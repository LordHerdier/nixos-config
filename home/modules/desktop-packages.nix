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
      loupe
      firefox
      fladder
      gimp
      gnome-keyring
      gparted
      libreoffice
      moonlight-qt
      nautilus
      remmina
      spotify
      tailscale
      thunar
      tsukimi
      # winboat  # pins EOL electron-40.10.5 (insecure); re-enable when nixpkgs bumps electron
    ]
  );
}
