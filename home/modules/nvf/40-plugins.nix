# home/modules/nvf/40-plugins.nix

{ ... }:

{
  config.vim = {
    filetree.nvimTree = {
      enable = true;
      openOnSetup = false;
      mappings = {
        toggle = "<leader>e";
      };
    };

    binds.whichKey.enable = true;
  };
}
