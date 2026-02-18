# home/modules/hyprland/default.nix

{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$mod" = "SUPER";

      bind = [
        "$mod, T, exec, kitty"
        "$mod, Q, killactive"
        "$mod, E, exec, wofi --show drun"
      ];

      exec-once = [
        "ambxst"
      ];

      input = {
        kb_layout = "colemak";
        follow_mouse = 1;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
      };
    };
  };
}
