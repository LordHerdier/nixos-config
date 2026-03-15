# home/modules/nvf/10-theme.nix

{ ... }:

{
  config.vim.theme = {
    enable = true;
    name = "catppuccin";
    style = "mocha";
  };
}
