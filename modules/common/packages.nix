# modules/common/packages.nix

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    at
    bc
    gnumake
    curl
    dnsutils
    wget
    fping
    fd
    eza
    htop
    tree
    zsh
    psmisc
    ncdu
    usbutils
  ];

  services.atd.enable = true;

  programs = {
    fuse.enable = true;
    zsh.enable = true;
    ssh.startAgent = false;
  };

}
