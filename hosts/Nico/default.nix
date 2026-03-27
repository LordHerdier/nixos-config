# hosts/Nico/default.nix

{ hostName, ... }:

{
  networking.hostName = hostName;
  imports = [
    ./networking.nix
    ../../modules/features/wsl-docker-desktop.nix
  ];

  system.stateVersion = "25.05";
}
