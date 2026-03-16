# home/modules/nvf/plugins/10-treesitter.nix

{ pkgs, ... }:

{
  config.vim = {
    treesitter = {
      enable = true;
      context.enable = true;
      grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        nix
        lua
        python
        bash
      ];
    };
  };
}
