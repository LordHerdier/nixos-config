# home/modules/hyprland/hypridle.nix
#
# Idle and lock handling for the dwl session only. Under Hyprland, Noctalia
# owns idle (home/modules/noctalia.nix); running both double-locked at 300 s
# and 600 s. The unit is therefore tied to dwl-session.target (defined in
# modules/features/dwl) instead of graphical-session.target, which both
# sessions start. A condition on XDG_CURRENT_DESKTOP wouldn't do: the user
# manager is shared between sessions and its environment goes stale.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # wlopm (wlr-output-power-management) rather than `hyprctl dispatch
  # dpms`: hypridle runs under dwl, not Hyprland, and wlopm talks to the
  # compositor on hypridle's own WAYLAND_DISPLAY, so stale environment in
  # the shared user manager can't point it at the wrong session.
  dpms = state: "${pkgs.wlopm}/bin/wlopm --${state} '*'";
in
{
  systemd.user.services.hypridle = {
    Unit = {
      PartOf = lib.mkForce [ "dwl-session.target" ];
      After = lib.mkForce [ "dwl-session.target" ];
    };
    Install.WantedBy = lib.mkForce [ "dwl-session.target" ];
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # hyprlock-colors seeds the color file if noctalia has never
        # rendered it (else hyprlock won't start); a no-op otherwise. Runs
        # before the `pidof` guard so a lock can't race the seeding.
        lock_cmd = "${config.my.hyprlock-colors.package}/bin/hyprlock-colors; pidof hyprlock || hyprlock";
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
