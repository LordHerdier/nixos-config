# modules/features/lean-specialisation.nix
#
# Boot-menu entry "lean" for battery / light work. Everything else is
# inherited from the normal Index config; only the deltas below apply.
#
# Only background services and EasyEffects go here. Measured on Index
# (idle, kitty + tmux, on battery) they were worth ~1.4 W of a ~7.7 W floor;
# the big costs were external hardware (Scarlett + dock, ~4.5 W), which no
# config can remove. PSR was tried (nixos-hardware's disablePsr = mkDefault
# true, dropped via mkForce false) and made no measurable difference, so it
# stays as nixos-hardware has it.
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

    # Mic/output effects chain (deepfilternet etc.) -- ~45% of a core.
    # Both users that import home/hosts/Index.nix get it, so force both off.
    home-manager.users = {
      charlotte.my.easyeffects.enable = lib.mkForce false;
      rivian.my.easyeffects.enable = lib.mkForce false;
    };
  };
}
