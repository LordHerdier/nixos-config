# home/modules/zsh/init/40-ssh-agent.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    # ssh-agent (WSL-proof)
    if [[ -z "$SSH_AUTH_SOCK" || ! -S "$SSH_AUTH_SOCK" ]]; then
      export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR:-/tmp}/ssh-agent.sock"
    fi
    if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
      mkdir -p "''${XDG_RUNTIME_DIR:-/tmp}"
      eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)" >/dev/null
    fi
  '';
}

