# home/modules/hyprland/hypridle.nix

{ config, ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # noctalia renders the generated color file itself now (see
        # hyprlock-colors.nix), so this is only the guard against it not
        # existing at all -- a host where noctalia has never run, where
        # `source`-ing it would otherwise stop hyprlock from coming up.
        # It is a no-op once the file is there, and runs before the
        # `pidof` guard so a lock cannot race the seeding.
        lock_cmd = [
          "${config.my.hyprlock-colors.package}/bin/hyprlock-colors; pidof hyprlock || hyprlock"
          "pidof mpvpaper || mpvpaper"
        ];
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 150;
          on-timeout = "bash -c 'brightnessctl get > /tmp/brightness_save && brightnessctl set 10'";
          on-resume = "bash -c 'brightnessctl set $(cat /tmp/brightness_save)'";
        }
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "bash -c 'hyprctl dispatch dpms on; brightnessctl set $(cat /tmp/brightness_save)'";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
