# home/modules/hyprland/40-design.nix

{ pkgs, ... }:

let
  cursorSize = 32;
in
{
  home.pointerCursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-light";
    size = cursorSize;
    hyprcursor = {
      enable = true;
      size = cursorSize;
    };
  };

  wayland.windowManager.hyprland.settings = {
    env = [
      "XCURSOR_SIZE,${toString cursorSize}"
      "XCURSOR_THEME,phinger-cursors-light"
      "HYPRCURSOR_SIZE,${toString cursorSize}"
      "HYPRCURSOR_THEME,phinger-cursors-light"
    ];

    animations = {
      enabled = true;
      bezier = "myBezier, 0, 1, 0.18, 1.0";
      animation = [
        "windows, 1, 1.5, myBezier"
        "windowsOut, 1, 2, myBezier, popin 95%"
        "border, 1, 12, myBezier"
        "borderangle, 1, 5, default"
        "fade, 1, 6, default"
        "workspaces, 1, 6, default"
      ];
    };

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 4;
      "col.active_border" = "rgba(113,255,255,0.33) rgba(82,113,163,0.3) 120deg";
      "col.inactive_border" = "rgba(89,70,196,0.3)";
      resize_on_border = true;
      layout = "dwindle";
      allow_tearing = false;
    };

    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
    };

    decoration = {
      rounding = 12;
      active_opacity = 0.95;
      inactive_opacity = 0.85;
      shadow = {
        enabled = true;
        range = 24;
        render_power = 5;
        color = "rgba(0,0,0,0.7)";
      };
      blur = {
        enabled = true;
        new_optimizations = true;
        size = 2;
        passes = 3;
        vibrancy = 0.2;
      };
    };

    dwindle = {
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };
  };
}
