# home/modules/zsh/init/20-zoxide.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    # Initialize zoxide for zsh - only if installed
    if command -v zoxide &> /dev/null; then
      eval "$(zoxide init zsh --cmd cd)"
    fi
  '';
}

