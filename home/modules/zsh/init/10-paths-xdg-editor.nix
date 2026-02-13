# home/modules/zsh/init/10-paths-xdg-editor.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    # Paths
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/bin:$PATH"

    path+=(
      "/mnt/c/Windows/System32"
      "/mnt/c/Windows"
      "/mnt/c/Program Files (x86)/GnuPG/bin"
      "/mnt/c/Program Files/Tailscale"
    )
    export PATH

    # XDG
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"

    # Editor
    export EDITOR=nvim
  '';
}

