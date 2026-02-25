# flake/hosts.nix

{
  "Charlie-Laptop" = {
    hostName = "Charlie-Laptop";
    isWsl = true;
    hostPath = ../hosts/Charlie-Laptop/default.nix;
  };

  "Nico" = {
    hostName = "Nico";
    isWsl = true;
    hostPath = ../hosts/Nico/default.nix;
  };

  "Pine" = {
    hostName = "Pine";
    isWsl = false;
    hostPath = ../hosts/Pine/default.nix;
  };
}
