# home/modules/zsh/init/61-manpager.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    # Set nvim as manpager if available
    if command -v nvim >/dev/null 2>&1; then
      export MANPAGER="nvim +Man!"
    fi
  '';
}
