# home/modules/zsh/wsl.nix

{ lib, isWsl, ... }:

{
  config = lib.mkIf isWsl {
    programs.zsh.shellAliases = {
      ts = "tailscale.exe";
      files = "explorer.exe .";
    };

    programs.zsh.initContent = lib.mkAfter ''
      copypath() {
        [[ -z "$1" ]] && return 1
        realpath "$1" | clip.exe
      }
    '';
  };
}
