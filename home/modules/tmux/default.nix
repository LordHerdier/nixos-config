# home/modules/tmux/default.nix

{  pkgs, ... }:

{
  imports = [
    ./00-core.nix
    ./10-keybinds.nix
    ./20-status-and-titles.nix
    ./30-colors-kanagawa.nix
    ./50-smart-vim.nix
  ];

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      resurrect
      continuum
    ];
  };
}

