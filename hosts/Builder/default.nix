# hosts/Builder/default.nix — headless remote build server, LXC 407 on twm (Proxmox)
#
# Built through mkHost with withHome = false: no home-manager, no desktop.
# Clients point at it with modules/features/remote-builder.nix.

{ ... }:

let
  # Dedicated key the clients' nix-daemons (root) use to reach `nixbuild`.
  # Public half only; the private half lives at /etc/nix/builder_ed25519
  # on each client.
  builderKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpfQeupDsnUW+8O3JTGa3h/DhbbkrbgOFdtYsFvkXZn nix-remote-builder";
in
{
  imports = [
    ../../modules/profiles/server.nix
    ../../modules/profiles/proxmox-lxc.nix
    ./ci.nix
  ];

  # Lower-case on purpose: it's the CT's existing hostname, which the
  # nixos-config attribute (`Builder`) doesn't have to match.
  networking.hostName = "builder";
  system.stateVersion = "25.11";

  # Network config comes from the CT's net0 (10.0.10.8/24 on the infra
  # bridge); Proxmox applies it, so nothing is declared here.

  # profiles/server.nix covers sshd and root's keys; just let the build
  # user in too.
  services.openssh.settings.AllowUsers = [ "nixbuild" ];

  users.users.nixbuild = {
    isNormalUser = true;
    description = "remote build target";
    openssh.authorizedKeys.keys = [ builderKey ];
  };

  # Binary cache for clients importing builder-cache.nix (which has the
  # public key). The signing key was generated once on the CT
  # (`nix-store --generate-binary-cache-key builder-1 ...`) and never
  # leaves it.
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
    # The disk is 120G: collect garbage mid-build instead of failing on it.
    min-free = 5 * 1024 * 1024 * 1024;
    max-free = 20 * 1024 * 1024 * 1024;
  };
}
