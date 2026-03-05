# modules/common/docker-desktop.nix

{ ... }:

{
  wsl.docker-desktop = {
    enable = true;
  };
}
