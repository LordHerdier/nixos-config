# hosts/Charlie-Laptop/default.nix

{ hostName, pkgs, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./networking.nix
    ../../modules/common/ssh.nix
    ../../modules/features/wsl-docker-desktop.nix
    ../../modules/features/syncthing.nix
  ];

  system.stateVersion = "25.05";

  programs.nix-ld.enable = true;

  users.users.charlotte.extraGroups = [ "kvm" ];

  # WSL2 creates /dev/kvm with a GID that doesn't match NixOS's kvm group
  systemd.tmpfiles.rules = [ "z /dev/kvm 0660 root kvm -" ];

  # WSL2 creates /dev/kvm well after systemd boots (and the tmpfiles rule above
  # has already run), so keep its group correct once it appears
  systemd.services.kvm-device-group = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.coreutils ];
    script = ''
      while true; do
        if [ -e /dev/kvm ] && [ "$(stat -c %G /dev/kvm)" != kvm ]; then
          chgrp kvm /dev/kvm
        fi
        sleep 2
      done
    '';
    serviceConfig.Restart = "always";
  };

}
