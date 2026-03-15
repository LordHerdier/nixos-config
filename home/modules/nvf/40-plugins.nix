# home/modules/nvf/40-plugins.nix

{ ... }:

{
  imports = [
    ./41-nvim-tree.nix
  ];

  config.vim = {
    binds.whichKey.enable = true;
  };
}
