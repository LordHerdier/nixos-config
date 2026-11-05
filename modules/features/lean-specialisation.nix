# modules/features/lean-specialisation.nix
#
# Boot-menu entry "lean" for battery / light work. Everything else is
# inherited from the normal Index config; only the deltas below apply.
#
# Only background services and EasyEffects go here. Findings from measuring
# Index (idle, kitty + tmux, on battery, 2026-11-05), for whoever revisits this:
#
#   15.3 W  starting point: external 1440p@120 monitor, Scarlett Solo, dock,
#           EasyEffects, all daemons, internal panel at 100% / 120 Hz
#   ~4.5-5.3 W  now: nothing external, power save on (60 Hz, 30%), settled
#
# What each step was worth:
#   - Scarlett + dock unplugged ........ ~4.5 W (hardware; no config can fix it)
#   - external monitor ................. ~1 W
#   - EasyEffects + daemons (this file)  ~1.4 W combined (EasyEffects alone
#                                        ~0.5 W despite using ~45% of a core)
#   - backlight 100% -> 30% ............ ~1 W; 30% -> 15% another ~0.17 W
#   - 120 -> 60 Hz ..................... ~0.1-0.4 W
#   - resolution 2880x1920 -> 1920x1200  no measurable change
#   - HDMI expansion card .............. ~0.1 W
#
# What is left is the hardware floor: the CPU package idles at ~1 W
# (turbostat), so ~3.5-4 W is the panel, DRAM, NVMe, Wi-Fi and board. ASPM
# L1/L1.2 is already on for NVMe and Wi-Fi, USB and most PCI functions are
# runtime-suspended, and the EPP is "power".
#
# PSR: nixos-hardware's Framework module disables it (disablePsr = mkDefault
# true, a workaround for amdgpu display bugs). Dropping that (mkForce false)
# makes it engage -- psr_state sits at 6 on an idle screen and falls to 0
# during activity -- but it changed the draw by less than the noise, since the
# display engine is a small part of a ~1 W SoC. Not worth carrying here.
# Note the draw takes 30-60 s to settle after any activity, so a quick
# reading overstates idle by ~0.3-0.5 W.
#
# The display side (60 Hz, ~30% brightness) is runtime state, not a boot
# option: toggle it with dwl-powersave (Super+Shift+P, scripts/dwl-powersave.sh)
# in any session, lean or not.
#
# tailscaled is deliberately kept: it reaches the remote builder / cache.
# Not covered: librepods, which dwl-startup launches directly rather than via
# a unit.

{ lib, ... }:

{
  specialisation.lean.configuration = {
    services = {
      syncthing.enable = lib.mkForce false;
      avahi.enable = lib.mkForce false;
      # bolt comes from the GNOME profile (mkDefault); fwupd from its default.
      hardware.bolt.enable = lib.mkForce false;
      fwupd.enable = lib.mkForce false;
      # iPhone USB pairing is unavailable in lean.
      usbmuxd.enable = lib.mkForce false;
    };

    # No CPU boost: caps burst power when something heavy does run. It has
    # no effect at idle (cores draw ~0.05 W), so this only matters under
    # load, where it trades peak speed for battery. amd_pstate=active
    # exposes the switch globally; tmpfiles writes it at boot and on switch.
    systemd.tmpfiles.rules = [ "w /sys/devices/system/cpu/cpufreq/boost - - - - 0" ];

    # Mic/output effects chain (deepfilternet etc.) -- ~45% of a core.
    # Both users that import home/hosts/Index.nix get it, so force both off.
    home-manager.users = {
      charlotte.my.easyeffects.enable = lib.mkForce false;
      rivian.my.easyeffects.enable = lib.mkForce false;
    };
  };
}
