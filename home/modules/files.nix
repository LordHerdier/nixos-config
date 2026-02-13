# home/modules/files.nix

{ dotfiles, ... }:

{
  home.file = {
    "bin" = {
      source = "${dotfiles}/bin/bin";
      recursive = true;
    };

    ".oh-my-posh" = {
      source = "${dotfiles}/omp/.oh-my-posh";
      recursive = true;
    };

    ".config/yazi" = {
      source = "${dotfiles}/yazi/.config/yazi";
      recursive = true;
    };
   
  };
}
