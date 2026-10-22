# modules/features/librepods.nix
#
# LibrePods: AirPods features (ANC/transparency control, ear detection,
# battery) outside Apple's ecosystem. The nixpkgs module installs a
# cap_net_admin wrapper that only members of the librepods group can run.

{ ... }:

{
  programs.librepods.enable = true;

  users.users.charlotte.extraGroups = [ "librepods" ];
}
