# home/modules/nvf/default.nix

{ pkgs, inputs, ... }:

let
  nvfConfig = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [
      {
        config.vim = {
          viAlias = false;
          vimAlias = false;

          # Basic quality-of-life to start
          options = {
            number = true;
            relativenumber = true;
            tabstop = 2;
            shiftwidth = 2;
            expandtab = true;
            wrap = false;
          };

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
          };
        };
      }
    ];
  };
in
{
  home.packages = [
    # Install as 'nvf' so it doesn't shadow existing 'nvim'
    (pkgs.writeShellScriptBin "nvf" ''
      exec ${nvfConfig.neovim}/bin/nvim "$@"
    '')
  ];
}
