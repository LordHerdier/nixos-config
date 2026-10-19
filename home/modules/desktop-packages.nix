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
      # spotify comes from ../modules/spicetify.nix as a patched build;
      # installing it here too would be a collision.
      tailscale
      thunar
      tsukimi
      # zen comes from ../modules/zen-browser as a home-manager-wrapped
      # build; installing the flake package here too is a collision.
      # winboat  # pins EOL electron-40.10.5 (insecure); re-enable when nixpkgs bumps electron
    ]
  );
}
