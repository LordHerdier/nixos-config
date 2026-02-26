# home/hosts/Charlie-Laptop.nix
{ ... }:
{
  imports = [
    ../profiles/wsl.nix
    ../modules/work-packages.nix
  ];
}
