# modules/features/wsl-docker-desktop.nix

{ ... }:

{
  wsl.docker-desktop = {
    enable = true;
  };

  users.users.charlotte.extraGroups = [ "docker" ];
}
