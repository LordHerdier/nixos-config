# modules/profiles/proxmox-vm.nix — NixOS as a Proxmox QEMU guest
#
# Pulls in nixpkgs' proxmox-image.nix, which supplies the disk layout
# (/ by label `nixos`, /boot by label `ESP`), grub, growpart and the qemu
# guest agent — and makes the host buildable as a restorable backup:
#
#   nix build /etc/nixos#nixosConfigurations.<Name>.config.system.build.VMA
#   scp result/*.vma.zst root@192.168.50.116:/var/lib/vz/dump/
#   qmrestore /var/lib/vz/dump/<file>.vma.zst <vmid> --unique true
#
# After that first boot, the VM is updated in place with
# `nh os switch --target-host root@<ip> -H <Name> /etc/nixos`, not by
# restoring a new image. Pair with profiles/server.nix.
#
# UEFI (OVMF), as on Apthos. Per-host size/cores/
# memory go in the host file under `proxmox.qemuConf` and only affect the
# image's embedded VM config (change a live VM's with `qm set` / Ansible's
# configure_vm.yml).

{
  hostName,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];

  proxmox.qemuConf = {
    bios = "ovmf";
    name = lib.mkDefault hostName;
  };

  # proxmox-image.nix turns cloud-init on by default, which force-blanks
  # networking.hostName and hands the network to cloud-init. Hosts here
  # declare their own address and name in Nix, so leave Proxmox's
  # cloud-init drive out of it.
  proxmox.cloudInit.enable = false;

  # proxmox-image.nix already puts the kernel console on ttyS0 (Proxmox's
  # serial0); mirror grub's menu there too, as on Apthos, so
  # `qm terminal <vmid>` shows the whole boot.
  boot.loader.grub.extraConfig = ''
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input --append serial
    terminal_output --append serial
  '';
}
