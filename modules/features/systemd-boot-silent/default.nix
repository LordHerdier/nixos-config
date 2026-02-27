# modules/features/systemd-boot-silent
# Credit to github:smravec/nixos-config

{ ... }:

{
  #  disabledModules = [
  #  "system/boot/stage-2.nix"
  #  "system/boot/stage-1.nix"
  #  "system/etc/etc.nix"
  #];

  imports = [
    #   ./stage-2-silent.nix
    #   ./stage-1-silent.nix
    #   ./etc-silent.nix
    ./boot.nix
  ];
}
