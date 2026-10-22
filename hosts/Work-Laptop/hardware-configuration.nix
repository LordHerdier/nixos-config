# PLACEHOLDER -- replace on the real machine.
#
# From the NixOS installer (or the installed system), run:
#   nixos-generate-config --show-hardware-config > hosts/Work-Laptop/hardware-configuration.nix
# This stub only exists so the host evaluates before the hardware does.
{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
