# modules/features/gvfs.nix

{ pkgs, ... }:

{
  services.gvfs.enable = true;
  environment.systemPackages = [
    pkgs.gvfs
  ];
  users.users.charlotte.extraGroups = [ "plugdev" ];
}
