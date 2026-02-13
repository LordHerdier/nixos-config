# home/modules/packages.nx

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    stylua
    shfmt
    shellcheck
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
    gh
    gnupg
    gcc
    coreutils
    procps
    yazi
    ffmpegthumbnailer
    poppler_utils
    unzip
    jq
    python3
    wl-clipboard
    wslu
  ];
}

