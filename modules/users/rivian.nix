# modules/users/rivian.nix
#
# Admin account mirroring charlotte's. Host-scoped on purpose — imported by
# Index only, not by modules/common/users.nix, same as kiddo.

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
