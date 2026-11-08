# modules/users/rivian.nix
#
# Admin account mirroring charlotte's. Imported by Index only, like kiddo.

{ pkgs, ... }:

{
  users.users.rivian = {
    isNormalUser = true;
    description = "Rivian";
    extraGroups = [
      "wheel"
      "input"
      "video"
    ];
    shell = pkgs.zsh;
  };
}
