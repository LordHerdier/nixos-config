# home/modules/zsh/init/10-paths-xdg-editor.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/bin:$PATH"

    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"

    export EDITOR=nvim
  '';
}

