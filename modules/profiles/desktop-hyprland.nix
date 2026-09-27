# modules/profiles/desktop-hyprland.nix

{ pkgs, ... }:

{
  imports = [ ./desktop-common.nix ];

  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    waybar
    wofi
    wl-clipboard
    grim
    slurp
    swappy
    networkmanagerapplet
    brightnessctl
    hyprpaper
    hyprpolkitagent
    (python3.withPackages (
      ps: with ps; [
        dbus-python
      ]
    ))
  ];

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}
