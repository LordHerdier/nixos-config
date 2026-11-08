# modules/features/lean-specialisation.nix
#
# Boot-menu entry "lean" for battery / light work: the normal Index config
# minus some background services and EasyEffects.
#
# Measurements (Index idle, kitty + tmux, on battery, 2026-11-05):
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
# The rest is hardware floor: CPU package ~1 W idle (turbostat), ~3.5-4 W
# panel, DRAM, NVMe, Wi-Fi and board. ASPM L1/L1.2 is on for NVMe and Wi-Fi,
# USB and most PCI functions runtime-suspend, EPP is "power".
#
# PSR: re-enabling it over nixos-hardware's disablePsr (an amdgpu
# workaround) makes it engage, but the change was within noise. Not worth
# carrying. Readings take 30-60 s to settle after activity; a quick one
# overstates idle by ~0.3-0.5 W.
#
# The display side (60 Hz, ~30% brightness) is runtime state: toggle it with
# dwl-powersave (Super+Shift+P, modules/features/dwl/scripts/) in either boot
# entry.
#
# tailscaled stays: it reaches the remote builder / cache. librepods only
# runs while an Apple device is connected, so it needs nothing here.

{ lib, ... }:

{
  specialisation.lean.configuration = {
    services = {
      avahi.enable = lib.mkForce false;
      # bolt comes from the GNOME profile (mkDefault); fwupd from its default.
      hardware.bolt.enable = lib.mkForce false;
      fwupd.enable = lib.mkForce false;
      # iPhone USB pairing is unavailable in lean.
      usbmuxd.enable = lib.mkForce false;
    };

    # No CPU boost: trades peak speed for battery under load (no effect at
    # idle). tmpfiles writes it at boot and on switch.
    systemd.tmpfiles.rules = [ "w /sys/devices/system/cpu/cpufreq/boost - - - - 0" ];

    # ~45% of a core. Both users importing home/hosts/Index.nix have it.
    home-manager.users = {
      charlotte.my.easyeffects.enable = lib.mkForce false;
      rivian.my.easyeffects.enable = lib.mkForce false;
    };
  };
}
