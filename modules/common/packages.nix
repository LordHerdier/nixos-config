# modules/packages.nix

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gnumake
    curl
    wget
    fd
    eza
    htop
    tree
    zsh
  ];

  programs = {
    zsh.enable = true;
    ssh.startAgent = false;
  };

}
