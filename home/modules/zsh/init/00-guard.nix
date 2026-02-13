# home/modules/zsh/init/00-guard.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkBefore ''
    # Only interactive shells
    [[ -o interactive ]] || return

    # make autosuggestions not stall the shell
    export ZSH_AUTOSUGGEST_USE_ASYNC=1
    export ZSH_AUTOSUGGEST_STRATEGY=(history)
    export ZSH_HIGHLIGHT_MAXLENGTH=300
  '';
}

