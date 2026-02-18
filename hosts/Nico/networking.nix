# hosts/Nico/networking.nix

{ ... }:

{
  networking = {
    nameservers = [ "192.168.50.123" "1.1.1.1" ];
    search = [ "lorscapa.arpa" "local.lorscapa.com" ];
  };

}
