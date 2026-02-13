# modules/users.nix

{ pkgs, ... }:

{
  users = {
    users = {
      charlotte = {
        isNormalUser = true;
        description = "Charlotte";
        extraGroups = [ "wheel" ];
        shell = pkgs.zsh;
      };
    };
  };

}

