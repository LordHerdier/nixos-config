# modules/networking.nix 

{ ... }:

{
  networking = {
    hostName = "Charlie-Laptop";
    nameservers = [ "146.163.252.126" ];
    search = [ "lorscapa.arpa" "siue.edu" "id.siue.edu" ];
  };
}
