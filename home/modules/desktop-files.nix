# home/modules/desktop-files.nix

{ dotfiles, ... }:

{
  home.file = {
    ".config/eww" = {
      source = "${dotfiles}/eww/.config/eww";
      recursive = true;
    };
    ".config/sddm" = {
      source = "${dotfiles}/sddm/.config/sddm";
      recursive = true;
    };
  };
}
