# home/modules/hyprland/40-design.nix

{ config, pkgs, ... }:

let
  cursorSize = 32;

  # The desktop's colors are noctalia's at runtime, but the window border
  # is not something noctalia can reach -- see the README's theme note.
  # So it is the one piece of Hyprland chrome that is declared, and it is
  # declared from `my.theme` rather than from literals.
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
    # hl.env takes the name and value as two arguments, so each entry is
    # an `_args` list rather than the old "NAME,VALUE" string.
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

    # `bezier = "myBezier, 0, 1, 0.18, 1.0"` -- the four numbers were the
    # two control points, which are now an explicit list of pairs.
    # hl.curve can also take `type = "spring"`, which hyprlang could not.
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

    # Was "NAME, ONOFF, SPEED, CURVE[, STYLE]" per line.
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

        # The quoted dotted keys are gone: col is a real nested table, and
        # a gradient is { colors, angle } instead of the hyprlang
        # "rgba(..) rgba(..) 120deg" string -- which is what lets the
        # roles below be dropped in with no string assembly.
        #
        # The gradient runs `border` -> `accentDim`, i.e. the border hue
        # fading toward the background, because no role names "the other
        # end of the active border" and inventing one for a single
        # consumer would be worse than deriving it.
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
