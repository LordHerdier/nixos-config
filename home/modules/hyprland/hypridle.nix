# home/modules/hyprland/hypridle.nix

{ ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = [
          "pidof hyprlock || hyprlock"
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
