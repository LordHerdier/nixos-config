# modules/profiles/dev-docker.nix

{ ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;

    # Keep container stdout out of the system journal: the NixOS default
    # "journald" lets a chatty test suite push tens of thousands of entries
    # a second. "local" keeps `docker logs` working via Docker's own
    # rotated, compressed per-container files.
    logDriver = "local";
  };

  users.users.charlotte.extraGroups = [ "docker" ];

  environment.sessionVariables.DOCKER_HOST = "unix:///var/run/docker.sock";
}
