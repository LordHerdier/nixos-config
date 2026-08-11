# home/modules/tmux/60-tmuxinator.nix
{ ... }:
{
  home.file.".config/tmuxinator/base.yml".text = ''
    name: base
    root: ~
    windows:
      - home:
          layout: main-vertical
          panes:
            - clear
      - downloads:
          root: ~/downloads
          panes:
            - clear
      - documents:
          root: ~/documents
          panes:
            - clear
      - winhome:
          root: ~/winhome
          panes:
            - clear
      - zsh:
          panes:
            - clear
  '';

  home.file.".config/tmuxinator/exo.yml".text = ''
    name: exo
    root: ~/documents/ExoDoom
    windows:
      - nvim:
          panes:
            - nvim
      - zsh:
          panes:
            - clear
      - zsh:
          panes:
            - clear
  '';

  home.file.".config/tmuxinator/homelab.yml".text = ''
    name: homelab
    root: ~
    windows:
      - zsh:
          panes:
            - clear
      - zsh:
          panes:
            - clear
      - infra:
          root: ~/documents/inframanagement
          panes:
            - clear
  '';

  home.file.".config/tmuxinator/nixos.yml".text = ''
    name: nixos
    root: ~
    windows:
      - nvim:nixos:
          root: /etc/nixos
          panes:
            - nvim
      - zsh:nixos:
          root: /etc/nixos
          panes:
            - clear
      - nvim:dotfiles:
          root: ~/Dotfiles
          panes:
            - nvim
      - zsh:dotfiles:
          root: ~/Dotfiles
          panes:
            - clear
      - zsh:
          panes:
            - clear
  '';

  home.file.".config/tmuxinator/work.yml".text = ''
    name: work
    root: ~/work
    windows:
      - connect:
          panes:
            - clear
      - class-prod:
          root: ~/work/classroom-production
          panes:
            - clear
      - ansible:
          panes:
            - clear
      - zsh:
          panes:
            - clear
  '';
  home.file.".config/tmuxinator/dev.yml".text = ''
    name: dev
    root: ~/documents/code
    windows:
      - berry:
          root: ~/documents/berrytree
          layout: main-vertical
          panes:
            - claude
            - nvim
            - [nix develop, cd companion]
  '';
}
