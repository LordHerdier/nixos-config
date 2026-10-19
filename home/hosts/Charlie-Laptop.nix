# home/hosts/Charlie-Laptop.nix
{ lib, ... }:
{
  imports = [ ../profiles/wsl.nix ];

  my.theme.default = lib.mkForce "kanagawa";
}
