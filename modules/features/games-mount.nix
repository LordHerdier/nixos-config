# modules/features/games-mount.nix
#
# Mounts the dedicated games partition at /mnt/games, owned by charlotte:users.

{ ... }:

{
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/fb3aea64-a3e8-4d91-96e4-dd29fdfaff65";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };

  systemd.tmpfiles.rules = [
    "z /mnt/games 0775 charlotte users -"
  ];
}
