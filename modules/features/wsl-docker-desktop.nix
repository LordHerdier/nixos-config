# modules/features/wsl-docker-desktop.nix

{ pkgs, ... }:

{
  wsl.docker-desktop = {
    enable = true;
  };

  # Docker Desktop probes the distro with `wsl.exe -e test -s <backend.sock>`.
  # -e execs directly with no shell, and neither /bin nor /usr/bin ships
  # `test`, so the integration check fails before reaching the socket.
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/test - - - - ${pkgs.coreutils}/bin/test"
  ];

  users.users.charlotte.extraGroups = [ "docker" ];
}
