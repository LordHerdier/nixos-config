# home/modules/packages.nx

{
  pkgs,
  inputs,
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
      deno # Peek nvim plugin requires this
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
      inputs.forgejo-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
      jq
      lazydocker
      lazygit
      mpv
      nerd-fonts.caskaydia-cove
      nmap
      nodejs
      oh-my-posh
      p7zip
      pass
      playerctl
      poppler-utils
      procps
      qemu
      ripgrep
      shellcheck
      shfmt
      sshpass
      stow
      stylua
      spotify-player
      tldr
      tmux
      unzip
      wl-clipboard
      yazi
      yt-dlp
      zoxide
    ]
  );
  #  ++ lib.optionals isWsl (with pkgs; [
  #    wslu
  #    win32yank
  #  ])
  #  ++ lib.optionals (!isWsl) [ pkgs.wl-clipboard ];
}
