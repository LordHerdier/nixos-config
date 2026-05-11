# hosts/Charlie-Laptop/networking.nix

{ ... }:

{
  networking = {
    nameservers = [
      "146.163.252.126"
      "146.163.252.127"
      "10.0.10.2"
    ];
    search = [
      "id.siue.edu"
      "siue.edu"
      "campus.siue.edu"
      "h.lorscapa.com"
    ];
  };

}
