# home/modules/files.nix

{ config, dotfiles, ... }:

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
    
    ".config/nvim" = {
      source = "${dotfiles}/nvim/.config/nvim";
      recursive = true;
    };

    ".config/nvim/lazy-lock.json" = {
      force = true;
      # Make it a symlink to the writable lockfile location
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.stateHome}/nvim/lazy/lazy-lock.json";
    };

  };
}
