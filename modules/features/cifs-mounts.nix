# modules/features/cifs-mounts.nix
#
# Mounts the SMB/CIFS shares from the NAS at 192.168.50.50.
#
# These use on-demand automount: nothing is mounted at boot, and the share is
# mounted transparently on first access to its mountpoint. Boot never blocks if
# the NAS is offline.
#
# Credentials live OUTSIDE the Nix store (which is world-readable) in a
# root-only file at /etc/nixos-secrets/smb-creds. Create it once with:
#
#   sudo install -d -m 700 /etc/nixos-secrets
#   sudo install -m 600 /dev/null /etc/nixos-secrets/smb-creds
#   sudoedit /etc/nixos-secrets/smb-creds
#
# File contents (no quotes):
#
#   username=YOUR_USER
#   password=YOUR_PASSWORD
#   domain=WORKGROUP        # optional; omit if not needed

{ pkgs, ... }:

let
  server = "192.168.50.50";
  credentialsFile = "/etc/nixos-secrets/smb-creds";

  commonOptions = [
    "credentials=${credentialsFile}"
    "vers=3.0"
    "uid=1000" # charlotte
    "gid=100" # users
    "file_mode=0664"
    "dir_mode=0775"
    "iocharset=utf8"
    "nofail"
    "noauto"
    "x-systemd.automount"
    "x-systemd.idle-timeout=600" # unmount after 10 min idle
    "x-systemd.device-timeout=10s"
    "x-systemd.mount-timeout=10s"
  ];
in
{
  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems."/mnt/Share" = {
    device = "//${server}/Share";
    fsType = "cifs";
    options = commonOptions;
  };

  fileSystems."/mnt/Media" = {
    device = "//${server}/Media";
    fsType = "cifs";
    options = commonOptions;
  };
}
