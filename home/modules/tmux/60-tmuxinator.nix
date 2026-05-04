# home/modules/tmux/60-tmuxinator.nix

{ ... }:

{
  home.file.".config/tmuxinator/home.yml".text = ''
    # ~/.config/tmuxinator/home.yml
    name: home
    root: ~

    windows:
      - home:
          layout: main-vertical
          panes:
            - clear
            - nvim
            - cd ~/Documents
  '';
}
