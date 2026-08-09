# modules/features/gvfs.nix

{ pkgs, ... }:

{
  services.gvfs.enable = true;
  environment.systemPackages = [
    pkgs.gvfs
    pkgs.simple-mtpfs
  ];
  users.users.charlotte.extraGroups = [ "plugdev" ];
}
