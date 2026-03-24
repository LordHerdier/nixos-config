# home/modules/hyprland/20-monitors.nix

{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-2,2560x1440@60,0x0,1"
      "eDP-1,2880x1920@120,auto,1.33"
      "DP-3,2560x1440@165,auto,1"
    ];

    workspace = [
      "2,monitor:DP-3"
      "1,monitor:eDP-1"
      "4,monitor:DP-3"
      "3,monitor:eDP-1"
      "6,monitor:DP-3"
      "5,monitor:eDP-1"
      "8,monitor:DP-3"
      "7,monitor:eDP-1"
      "10,monitor:DP-3"
      "11,monitor:eDP-1"
    ];
  };
}
