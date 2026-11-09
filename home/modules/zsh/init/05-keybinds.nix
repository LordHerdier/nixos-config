# home/modules/zsh/init/05-keybinds.nix

{ lib, ... }:

{
  # mkBefore: zsh auto-selects vi mode because EDITOR=nvim contains "vi", and
  # `bindkey -e` re-links the main keymap, so it must run before atuin's
  # integration binds ^R / up-arrow.
  programs.zsh.initContent = lib.mkBefore ''
    bindkey -e

    # Ctrl+x Ctrl+e: edit the current line in $EDITOR
    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey '^x^e' edit-command-line

    # Alt+#: park the line as a comment
    setopt interactivecomments
    bindkey '^[#' pound-insert

    # Alt+*: expand glob in place; Alt+Ctrl+e: expand history/aliases/vars
    bindkey '^[*' expand-word
    bindkey '^[^e' expand-history
  '';
}
