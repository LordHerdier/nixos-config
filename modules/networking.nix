# modules/networking.nix 

{ ... }:

{
  networking = {
    hostName = "Charlie-Laptop";
    search = [ "lorscapa.arpa" "siue.edu" "id.siue.edu" ];
  };
}
