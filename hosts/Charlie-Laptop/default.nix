# hosts/Charlie-Laptop/default.nix

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./networking.nix
  ];

  system.stateVersion = "25.05";

}
