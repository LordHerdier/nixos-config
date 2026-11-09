# home/profiles/wsl.nix
{ lib, isWsl, ... }:

{
  imports = [
    ../modules/tmux/40-url-helpers.nix
    ../modules/zsh/wsl.nix
  ];

  config = lib.mkIf isWsl {
    programs.zsh.initContent = lib.mkAfter ''
      path+=(
        "/mnt/c/Windows/System32"
        "/mnt/c/Windows"
        "/mnt/c/Program Files/Tailscale"
      )
      export PATH
    '';
  };
}
