# home/modules/tmux/default.nix

{ pkgs, ... }:

{
  imports = [
    ./00-core.nix
    ./10-keybinds.nix
    ./20-status-and-titles.nix
    ./30-colors.nix
    ./50-smart-vim.nix
    ./60-tmuxinator.nix
    ./70-utilities.nix
  ];

  home.packages = [ pkgs.tmuxinator ];

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
    ];
  };
}
