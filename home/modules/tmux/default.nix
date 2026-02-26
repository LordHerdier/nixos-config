# home/modules/tmux/default.nix

{ pkgs, lib, ... }:

let
  tmux-session-dots = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-session-dots";
    version = "unstable=2026-02-14";

    rtpFilePath = "session-dots.tmux";

    src = pkgs.fetchFromGitHub {
      owner = "jtmcginty";
      repo = "tmux-session-dots";
      rev = "992a6c76e42bdd1b1a6f082216a13c94ebaffc34";
      sha256 = "lI5aOGHubu2kWGPaOvUkjcwUgRnaW//YA3PAazqZcjg=";
    };
  };
in
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
      tmux-session-dots
    ];

    # Force-run the tmux-session-dots plugin
    extraConfig = lib.mkAfter ''
      run-shell "${tmux-session-dots}/share/tmux-plugins/tmux-session-dots/session-dots.tmux"
    '';
  };
}
