# modules/profiles/dev-docker.nix

{ ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  users.users.charlotte.extraGroups = [ "docker" ];

  environment.sessionVariables.DOCKER_HOST = "unix:///var/run/docker.sock";
}
