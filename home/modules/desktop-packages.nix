# home/modules/desktop-packages.nix

{ pkgs, ... }:

{
  home.packages = (
    with pkgs;
    [
      firefox
      audacity
      gimp
      nautilus
      xfce.thunar
      tailscale
      mpvpaper
      hyprpaper
      spotify
      discord
      remmina
      moonlight-qt
      steam
    ]
  );
}
