# modules/features/remote-builder.nix — offload builds to the `builder` CT on twm
#
# Needs the private key at /etc/nix/builder_ed25519 (root-owned, 0600); the
# matching public key is authorised in hosts/Builder/default.nix. If the
# builder is unreachable nix just builds locally and the cache is skipped.

{ ... }:

{
  nix.distributedBuilds = true;

  nix.buildMachines = [
    {
      hostName = "10.0.10.8";
      sshUser = "nixbuild";
      sshKey = "/etc/nix/builder_ed25519";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 4;
      speedFactor = 4;
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
      ];
    }
  ];

  # Let the builder pull from cache.nixos.org itself instead of having this
  # machine upload every dependency.
  nix.settings.builders-use-substitutes = true;

  # The builder also serves its store as a binary cache (harmonia), so
  # machines using it fetch what it has already built.
  nix.settings.substituters = [ "http://10.0.10.8:5000" ];
  nix.settings.trusted-public-keys = [ "builder-1:MPHoCtlo1Bgo7IWe1JPW+lNiniH8jshy4rmbmFBRro4=" ];

  programs.ssh.knownHosts."10.0.10.8".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELmPUH6WltNLjSoM26m9+ggSwh/GbyYxAAbapprKxvU";
}
