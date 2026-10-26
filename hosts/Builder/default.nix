# hosts/Builder/default.nix — headless remote build server, LXC 407 on twm (Proxmox)
#
# Not built through mkHost: no home-manager, no desktop, no per-user config.
# Clients point at it with modules/features/remote-builder.nix.

{ modulesPath, ... }:

let
  # Dedicated key the clients' nix-daemons (root) use to reach `nixbuild`.
  # Public half only; the private half lives at /etc/nix/builder_ed25519
  # on each client.
  builderKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpfQeupDsnUW+8O3JTGa3h/DhbbkrbgOFdtYsFvkXZn nix-remote-builder";

  # Charlotte's interactive key, for root so `nixos-rebuild --target-host`
  # works against this box.
  adminKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMkOTHjuB7f+raL44rpjdwHWlbiODQGdqj3fpVmX9VUu charlotte@pine";
in
{
  imports = [
    "${modulesPath}/virtualisation/proxmox-lxc.nix"
    ../../modules/common/nix.nix
    ./ci.nix
  ];

  networking.hostName = "builder";
  system.stateVersion = "25.11";
  time.timeZone = "America/Chicago";

  # Network config comes from the CT's net0 (10.0.10.8/24 on the infra
  # bridge); Proxmox applies it, so nothing is declared here.

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitEmptyPasswords = false;
      PermitRootLogin = "prohibit-password";
      AllowUsers = [
        "root"
        "nixbuild"
      ];
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [ adminKey ];

  users.users.nixbuild = {
    isNormalUser = true;
    description = "remote build target";
    openssh.authorizedKeys.keys = [ builderKey ];
  };

  # Serves this box's /nix/store as a binary cache for the clients that use
  # modules/features/remote-builder.nix. The signing key is generated once
  # on the CT (`nix-store --generate-binary-cache-key builder-1 ...`) and
  # never leaves it; the public half is in remote-builder.nix.
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ "/var/lib/harmonia/cache-sk" ];
    settings.bind = "0.0.0.0:5000";
  };
  networking.firewall.allowedTCPPorts = [ 5000 ];

  nix.settings = {
    trusted-users = [ "nixbuild" ];
    max-jobs = 4;
    cores = 0; # each job may use every core
    # The disk is ~80G: collect garbage mid-build instead of failing on it.
    min-free = 5 * 1024 * 1024 * 1024;
    max-free = 20 * 1024 * 1024 * 1024;
  };
}
