# home/modules/desktop-files.nix

{ dotfiles, ambxst, ... }:

{
  home.file = {
    ".config/hypr" = {
      source = "${dotfiles}/hypr/.config/hypr";
      recursive = true;
    };
    ".config/eww" = {
      source = "${dotfiles}/eww/.config/eww";
      recursive = true;
    };
    ".config/sddm" = {
      source = "${dotfiles}/sddm/.config/sddm";
      recursive = true;
    };
    ".config/ambxst" = {
      source = "${dotfiles}/ambxst/.config/ambxst";
      recursive = true;
    };
  };
}
