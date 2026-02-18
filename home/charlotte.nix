# home/charlotte.nix

{ hostName, isWsl, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/files.nix
    ./modules/git.nix
    ./modules/nvim.nix
    ./modules/gnupg.nix
    ./modules/atuin.nix
    ./modules/zsh
    ./modules/tmux
  ];

  home.sessionVariables = {
    NIX_HOST = hostName;
    IS_WSL = if isWsl then "1" else "0";
  };

  home.username = "charlotte";
  home.homeDirectory = "/home/charlotte";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}

