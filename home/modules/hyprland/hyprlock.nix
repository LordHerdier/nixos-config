# home/modules/hyprland/hyprlock.nix

{ ... }:

{
  programs.hyprlock = {
    enable = true;
    extraConfig = ''
      source = ~/.config/Ax-Shell/config/hypr/colors.conf

      background {
          monitor =
          path = ~/.current.wall
          blur_passes = 3
          blur_size = 3
          contrast = 1.0
          brightness = 0.5
          vibrancy = 0.0
          vibrancy_darkness = 0.0
      }

      general {
          grace = 0
          hide_cursor = true
      }

      input-field {
          monitor =
          size = 256, 48
          outline_thickness = 0
          dots_size = 0.2
          dots_spacing = 0.5
          dots_center = true
          outer_color = rgba(00000000)
          inner_color = rgba(0, 0, 0, 1)
          font_color = rgb($foreground)
          fail_color = rgb($error)
          check_color = rgb($tertiary)
          capslock_color = rgb($secondary)
          fade_on_empty = false
          font_family = Iosevka Nerd Font
          placeholder_text = ...
          hide_input = false
          position = 0, -100
          halign = center
          valign = center
          shadow_passes = 1
          shadow_size = 5
          shadow_boost = 0.5
      }

      label {
          monitor =
          text = cmd[update:1000] echo "$(date +"%H:%M:%S")"
          color = rgb($foreground)
          font_size = 14
          font_family = Iosevka Nerd Font Bold
          position = 0, -150
          halign = center
          valign = center
          shadow_passes = 1
          shadow_size = 5
          shadow_boost = 0.5
      }

      label {
          monitor =
          text = cmd[update:1000] echo "$USER@$(hostname)"
          color = rgb($foreground)
          font_size = 14
          font_family = Iosevka Nerd Font Bold Italic
          position = 0, -50
          halign = center
          valign = center
          shadow_passes = 1
          shadow_size = 5
          shadow_boost = 0.5
      }

      image {
          path = .face.icon
          size = 200
          position = 0, 75
          halign = center
          valign = center
          border_size = 3
          border_color = rgb($primary)
          shadow_passes = 1
          shadow_size = 5
          shadow_boost = 0.5
      }
    '';
  };
}
