# modules/packages.nix

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    at
    gnumake
    curl
    wget
    fd
    eza
    htop
    tree
    zsh
    psmisc
  ];

  services.atd.enable = true;

  programs = {
    zsh.enable = true;
    ssh.startAgent = false;
  };

}
