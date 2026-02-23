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
    binwalk
    unzip
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
    poppler-utils
    unzip
    jq
    python3
    qemu
    wl-clipboard
    nerd-fonts.caskaydia-cove
    nmap
   ]);
#  ++ lib.optionals isWsl (with pkgs; [
#    wslu
#    win32yank
#  ])
#  ++ lib.optionals (!isWsl) [ pkgs.wl-clipboard ];
}

