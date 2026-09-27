# home/modules/desktop-files.nix

{ dotfiles, ... }:

{
  home.file = {
    ".config/sddm" = {
      source = "${dotfiles}/sddm/.config/sddm";
      recursive = true;
    };
  };
}
