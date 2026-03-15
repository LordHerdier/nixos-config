# home/modules/nvf/10-theme.nix

{ pkgs, ... }:

{
  config.vim = {
    # Don't use the built-in theme system
    theme.enable = false;

    extraPlugins = {
      nightfox = {
        package = pkgs.vimPlugins.nightfox-nvim;
      };
    };

    luaConfigRC.theme = # lua
      ''
        require("nightfox").setup({
          palettes = {
            all = {
              black    = "#1D2021",
              red      = { base = "#CC241D", bright = "#F42C3E" },
              green    = { base = "#98971A", bright = "#B8BB26" },
              yellow   = { base = "#D79921", bright = "#FABD2F" },
              blue     = { base = "#458588", bright = "#99C6CA" },
              magenta  = { base = "#B16286", bright = "#D3869B" },
              cyan     = { base = "#689D6A", bright = "#7EC16E" },
              white    = { base = "#A89984", bright = "#EBDBB2" },
              bg0      = "#181921",
              fg1      = "#EBDBB2",
            },
          },
          options = {
            transparent    = true,
            terminal_colors = false,
            -- dim_inactive   = true,
          },
        })
        vim.cmd("colorscheme nightfox")
      '';
  };
}
