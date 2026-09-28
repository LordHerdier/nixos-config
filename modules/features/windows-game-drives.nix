# modules/features/windows-game-drives.nix
#
# Mounts the NTFS game/data partitions shared with the Windows VM (100) on
# twm. Both VMs pass through the same physical disks and share a single GPU
# mapping, so they're never running at the same time — safe to read/write
# these from either side as long as that stays true.

{ ... }:

{
  fileSystems."/mnt/windows-games" = {
    device = "/dev/disk/by-uuid/54FA0E4CFA0E2B36"; # nvme1n1p2, label "TWM"
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };

  fileSystems."/mnt/yato" = {
    device = "/dev/disk/by-uuid/1696D9BE96D99E95"; # sda2, label "Yato"
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };
}
