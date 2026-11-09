# modules/common/nh.nix
#
# nh: nixos-rebuild wrapper with nix-output-monitor and closure diffs.
# `nh os switch` picks up the flake from NH_FLAKE and the host from hostname.
# GC stays with nix.gc in nix.nix, so nh.clean is left off.

{
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };
}
