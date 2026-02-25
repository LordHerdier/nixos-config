# modules/profiles/dev-docker.nix

{ ... }:

{
  virtualisation.docker = {
    enable = true;
  };

  users.users.charlotte.extraGroups = [ "docker" ];
}
