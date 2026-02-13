# home/modules/packages.nx

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    oh-my-posh
    pass
    sshpass
    stow
    zoxide
    tmux
    fzf
    ripgrep
    gnugrep
    gnused
    coreutils
    procps
    yazi
    ffmpegthumbnailer
    poppler_utils
    unzip
    jq
    wl-clipboard
    wslu
  ];
}

