# hosts/Charlie-Laptop/networking.nix

{ ... }:

{
  networking = {
    nameservers = [ "146.163.252.126" "146.163.252.127" ];
    search = [ "lorscapa.arpa" "siue.edu" "id.siue.edu" ];
  };

}
