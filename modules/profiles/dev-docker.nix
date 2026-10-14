# modules/profiles/dev-docker.nix

{ ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;

    # Keep container stdout out of the system journal. The upstream NixOS
    # default is "journald", which sends every line a container prints into
    # journald -- a chatty test suite can push tens of thousands of entries
    # in a single second, starve the rest of the system and bloat the
    # journal. "local" keeps `docker logs` working but writes to Docker's
    # own rotated, compressed per-container files instead.
    logDriver = "local";
  };

  users.users.charlotte.extraGroups = [ "docker" ];

  environment.sessionVariables.DOCKER_HOST = "unix:///var/run/docker.sock";
}
