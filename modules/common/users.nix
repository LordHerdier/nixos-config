# modules/users.nix

{ pkgs, ... }:

{
  users = {
    users = {
      charlotte = {
        isNormalUser = true;
        description = "Charlotte";
        extraGroups = [
          "wheel"
          "input"
          "video"
        ];
        shell = pkgs.zsh;
      };
    };
  };

}
