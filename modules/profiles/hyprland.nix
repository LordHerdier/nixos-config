# modules/profiles/hyprland.nix

{ config,, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  services.pipewire = {

  enable = true;
  pulse.enable = true;
  alsa.enable = true;
  };

  security.rtkit.enable = true;

  hardware.opengl.enable = true;

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
  ];

  fonts.packages = with pkgs; [
    nerdfonts
    noto-fonts
    noto-fonts-emoji
  ];
