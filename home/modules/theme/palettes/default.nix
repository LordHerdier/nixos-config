# home/modules/theme/palettes/default.nix
#
# The palette registry. Plain attrset of name -> unresolved palette file;
# home/modules/theme/default.nix runs each through `mkTheme` to fill in
# role defaults and exposes the result as `my.theme.palettes`.
#
# Importable on its own (no lib, no pkgs, no module system) so a
# derivation can read a palette directly.

{
  kanagawa = import ./kanagawa.nix;
  catppuccin-mocha = import ./catppuccin-mocha.nix;
  gruvbox-nightfox = import ./gruvbox-nightfox.nix;
  oneshot = import ./oneshot.nix;
}
