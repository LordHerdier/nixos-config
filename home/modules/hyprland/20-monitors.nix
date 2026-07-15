# home/modules/hyprland/20-monitors.nix

{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # "DP-2,2560x1440@60,0x0,1"
      "eDP-1,2880x1920@120,0x0,1.33"
      # "eDP-1, 1920x1080@120, auto, 1"
      "DP-2,2560x1440@165,0x-1440,1"
      # ",1920x1080,auto,1"
      # ",1920x1080,auto,1,mirror/* , */eDP-1"
    ];

    workspace = [
      "2,monitor:DP-2"
      "1,monitor:eDP-1"
      "4,monitor:DP-2"
      "3,monitor:eDP-1"
      "6,monitor:DP-2"
      "5,monitor:eDP-1"
      "8,monitor:DP-2"
      "7,monitor:eDP-1"
      "10,monitor:DP-2"
      "11,monitor:eDP-1"
    ];
  };
}
