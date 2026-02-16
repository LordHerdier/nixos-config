# modules/profiles/hyprland.nix

{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
  };

    xdg.portal.config.common.default = "*";


  services.pipewire = {

  enable = true;
  pulse.enable = true;
  alsa.enable = true;
  };

  security.rtkit.enable = true;

  hardware.graphics.enable = true;

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

#  fonts.packages = with pkgs; [
#    nerdfonts
#    noto-fonts
#    noto-fonts-emoji
#  ];
}
