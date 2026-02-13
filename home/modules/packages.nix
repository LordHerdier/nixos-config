# home/modules/packages.nx

{ pkgs, lib, isWsl, ... }:

{
  home.packages = (with pkgs; [
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
  ])
  ++ lib.optionals isWsl [ pkgs.wslu ]
  ++ lib.optionals (!isWsl) [ pkgs.wl-clipboard ];
}

