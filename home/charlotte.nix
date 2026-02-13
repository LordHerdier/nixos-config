# home/charlotte.nix

{ config, pkgs, dotfiles, ... }:

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

  home.username = "charlotte";
  home.homeDirectory = "/home/charlotte";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}

