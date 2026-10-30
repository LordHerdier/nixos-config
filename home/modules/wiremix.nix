# home/modules/wiremix.nix
#
# wiremix, the PipeWire mixer behind dwl's Super+A popup (dwl-modal in
# modules/features/dwl.nix). The package itself is installed system-wide
# there; this only writes ~/.config/wiremix/wiremix.toml.

{ ... }:

let
  bind = key: action: {
    key.Char = key;
    inherit action;
  };
in
{
  programs.wiremix = {
    enable = true;

    # Merged over wiremix's defaults, so only the vi keys are replaced; the
    # arrows, Tab and everything else keep their default actions.
    settings.keybindings = [
      # Colemak n/e/u/i = left/down/up/right, matching nvim/tmux/spotify-player
      (bind "n" { SetRelativeVolume = -0.01; })
      (bind "i" { SetRelativeVolume = 0.01; })
      (bind "u" "MoveUp")
      (bind "e" "MoveDown")
      (bind "N" "TabLeft")
      (bind "I" "TabRight")

      # Drop the defaults we just moved off of
      (bind "h" "Nothing")
      (bind "j" "Nothing")
      (bind "k" "Nothing")
      (bind "l" "Nothing")
      (bind "H" "Nothing")
      (bind "L" "Nothing")
    ];
  };
}
