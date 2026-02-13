# hosts/Pine/default.nix

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  system.stateVersion = "25.05";

  # laptop-only stuff (wifi, bluetooth, graphics, etc) goes here
}
