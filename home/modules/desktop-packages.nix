# home/modules/desktop-packages.nix

{ pkgs, ... }:

{
  home.packages = (
    with pkgs;
    [
      # audacity 4.0.0 fails to build against Qt 6.12 (QML AOT cache); use 3.x until fixed
      audacity_3
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
      # spotify comes from ./spicetify.nix (patched); adding it here collides.
      tailscale
      thunar
      # nixpkgs' cargo hook exports AWS_LC_SYS_USE_SYSTEM=1 but no system
      # AWS-LC is provided; build aws-lc-sys from source instead.
      (tsukimi.overrideAttrs (old: {
        preBuild = (old.preBuild or "") + ''
          unset AWS_LC_SYS_USE_SYSTEM
        '';
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ cmake ];
      }))
      # zen comes from ./zen-browser (HM-wrapped); adding it here collides.
      # winboat  # pins EOL electron-40.10.5 (insecure); re-enable when nixpkgs bumps electron
    ]
  );
}
