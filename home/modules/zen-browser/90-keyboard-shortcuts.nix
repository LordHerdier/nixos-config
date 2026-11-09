# home/modules/zen-browser/90-keyboard-shortcuts.nix
#
# Shortcut overrides, written to zen-keyboard-shortcuts.json (locked
# while Zen runs -- close it before a switch).
#
# `keyboardShortcutsVersion` is a guard, not a preference: activation
# fails if Zen's own schema version has moved on, rather than silently
# writing shortcuts the new browser will ignore. Read the current value
# from zen.keyboard.shortcuts.version in about:config and bump it here
# after checking the ids still exist.
#
# Find ids with:
#   jq -c '.shortcuts[] | {id, key, keycode, action}' \
#     ~/.config/zen/default/zen-keyboard-shortcuts.json | fzf
{ ... }:

{
  programs.zen-browser.profiles.default = {
    # keyboardShortcutsVersion = 17;
    # keyboardShortcuts = [
    #   {
    #     id = "zen-compact-mode-toggle";
    #     key = "c";
    #     modifiers = {
    #       control = true;
    #       alt = true;
    #     };
    #   }
    #   {
    #     id = "key_quitApplication";
    #     disabled = true;
    #   }
    # ];
  };
}
