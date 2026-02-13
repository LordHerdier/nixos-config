# home/modules/zsh/init/50-history-completion.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    # History
    HISTFILE=~/.zsh_history
    HISTSIZE=3000
    SAVEHIST=5000
    setopt append_history inc_append_history share_history
    setopt HIST_IGNORE_SPACE

    # Completion matcher
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
  '';
}

