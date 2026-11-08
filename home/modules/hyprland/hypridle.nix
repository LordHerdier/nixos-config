# home/modules/hyprland/hypridle.nix

{ config, pkgs, ... }:

let
  # wlopm (wlr-output-power-management) rather than `hyprctl dispatch
  # dpms`: hypridle also runs under dwl (both sessions start
  # graphical-session.target), and wlopm talks to the compositor on
  # hypridle's own WAYLAND_DISPLAY, so stale environment in the shared
  # user manager can't point it at the wrong session.
  dpms = state: "${pkgs.wlopm}/bin/wlopm --${state} '*'";
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # hyprlock-colors seeds the color file if noctalia has never
        # rendered it (else hyprlock won't start); a no-op otherwise. Runs
        # before the `pidof` guard so a lock can't race the seeding.
        lock_cmd = [
          "${config.my.hyprlock-colors.package}/bin/hyprlock-colors; pidof hyprlock || hyprlock"
          "pidof mpvpaper || mpvpaper"
        ];
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = dpms "on";
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
          on-timeout = dpms "off";
          on-resume = "bash -c \"${dpms "on"}; brightnessctl set $(cat /tmp/brightness_save)\"";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
