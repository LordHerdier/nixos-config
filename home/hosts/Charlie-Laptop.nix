# home/hosts/Charlie-Laptop.nix
{ lib, ... }:
{
  imports = [ ../profiles/wsl.nix ];

  my.theme.default = lib.mkForce "kanagawa";

  programs.git.settings.user.email = lib.mkForce "brennwh@siue.edu";
}
