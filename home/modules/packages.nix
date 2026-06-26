# home/modules/packages.nx

{
  pkgs,
  ...
}:

{
  home.packages = (
    with pkgs;
    [
      (python3.withPackages (ps: with ps; [ packaging ]))
      (ansible.overrideAttrs (old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ python3Packages.paramiko ];
      }))
      binwalk
      concord
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
      qemu
      ripgrep
      shellcheck
      shfmt
      sshpass
      stow
      stylua
      tldr
      tmux
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
