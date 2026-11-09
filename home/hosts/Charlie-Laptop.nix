# home/hosts/Charlie-Laptop.nix
{ lib, ... }:
{
  imports = [ ../profiles/wsl.nix ];

  my.theme.default = lib.mkForce "kanagawa";

  programs.git.settings.user.email = lib.mkForce "brennwh@siue.edu";
  programs.git.signing = {
    key = "DF13F0978656F01D";
    signByDefault = true;
  };
}
