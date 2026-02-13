# home/modules/zsh/init/99-private-extras.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    # Source optional private extras (kept as external files)
    for file in ~/.secrets.zsh ~/.ssh_aliases.zsh; do
      [[ -f "$file" ]] && source "$file"
    done
  '';
}

