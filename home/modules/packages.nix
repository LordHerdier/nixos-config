# home/modules/packages.nx

{
  pkgs,
  ...
}:

{
  home.packages = (
    with pkgs;
    [
      ansible
      binwalk
      bun
      claude-code
      coreutils
      fastfetch
      ffmpegthumbnailer
      fzf
      gcc
      gh
      gnugrep
      gnupg
      gnused
      inetutils
      jq
      nerd-fonts.caskaydia-cove
      nmap
      nodejs
      oh-my-posh
      pass
      poppler-utils
      procps
      python3
      qemu
      ripgrep
      shellcheck
      shfmt
      sshpass
      stow
      stylua
      tmux
      unzip
      unzip
      wl-clipboard
      yazi
      zoxide
    ]
  );
  #  ++ lib.optionals isWsl (with pkgs; [
  #    wslu
  #    win32yank
  #  ])
  #  ++ lib.optionals (!isWsl) [ pkgs.wl-clipboard ];
}
