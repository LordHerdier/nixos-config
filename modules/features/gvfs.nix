# modules/features/gvfs.nix

{ pkgs, ... }:

{
  services.gvfs.enable = true;
  environment.systemPackages = [
    pkgs.gvfs
    pkgs.jmtpfs
  ];
  users.users.charlotte.extraGroups = [ "plugdev" ];
}
