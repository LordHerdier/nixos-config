# home/modules/hyprland/40-design.nix

{ config, pkgs, ... }:

let
  cursorSize = 32;

  # Desktop colors are noctalia's at runtime, but it can't reach the
  # window border, so that is declared from `my.theme`.
  r = config.my.theme.active.roles;
  inherit (config.my.theme.lib) rgbaCsv;
in
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-light";
    size = cursorSize;
    hyprcursor = {
      enable = true;
      size = cursorSize;
    };
  };

  wayland.windowManager.hyprland.settings = {
    # hl.env takes name and value as two arguments, hence `_args`.
    env = [
      {
        _args = [
          "XCURSOR_SIZE"
          (toString cursorSize)
        ];
      }
      {
        _args = [
          "XCURSOR_THEME"
          "phinger-cursors-light"
        ];
      }
      {
        _args = [
          "HYPRCURSOR_SIZE"
          (toString cursorSize)
        ];
      }
      {
        _args = [
          "HYPRCURSOR_THEME"
          "phinger-cursors-light"
        ];
      }
    ];

    # Bezier control points (0,1) and (0.18,1.0). hl.curve also accepts
    # `type = "spring"`.
    curve = [
      {
        _args = [
          "myBezier"
          {
            type = "bezier";
            points = [
              [
                0
                1
              ]
              [
                0.18
                1.0
              ]
            ];
          }
        ];
      }
    ];

    animation = [
      {
        leaf = "windows";
        enabled = true;
        speed = 1.5;
        bezier = "myBezier";
      }
      {
        leaf = "windowsOut";
        enabled = true;
        speed = 2;
        bezier = "myBezier";
        style = "popin 95%";
      }
      {
        leaf = "border";
        enabled = true;
        speed = 12;
        bezier = "myBezier";
      }
      {
        leaf = "borderangle";
        enabled = true;
        speed = 5;
        bezier = "default";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 6;
        bezier = "default";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 6;
        bezier = "default";
      }
    ];

    config = {
      animations.enabled = true;

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 4;

        # Gradient runs `border` -> `accentDim` (the border hue fading
        # toward the background): no role names "the other end of the
        # active border", and one consumer doesn't justify inventing one.
        col = {
          active_border = {
            colors = [
              (rgbaCsv r.border 0.33)
              (rgbaCsv r.accentDim 0.3)
            ];
            angle = 120;
          };
          inactive_border = rgbaCsv r.borderInactive 0.3;
        };

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
  };
}
