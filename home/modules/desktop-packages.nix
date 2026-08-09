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
      loupe
      libreoffice
      moonlight-qt
      nautilus
      mpvpaper
      remmina
      spotify
      tailscale
      thunar
      tsukimi
      # winboat  # pins EOL electron-40.10.5 (insecure); re-enable when nixpkgs bumps electron
    ]
  );
}
