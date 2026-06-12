# hosts/Apthos/networking.nix

{ ... }:

{
  networking = {
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    networkmanager.enable = true;
  };
}
