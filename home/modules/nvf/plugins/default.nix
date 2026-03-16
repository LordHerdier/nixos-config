# home/modules/nvf/plugins/default.nix

{ lib, ... }:

{
  imports =
    let
      dir = ./.;
      files = builtins.attrNames (builtins.readDir dir);
      nixFiles = builtins.filter (f: f != "default.nix" && lib.hasSuffix ".nix" f) files;
    in
    map (f: dir + "/${f}") nixFiles;

  config.vim = {
    spellcheck.enable = true;

    binds.whichKey.enable = true;
    binds.cheatsheet.enable = true;

    notify.nvim-notify.enable = true;

    tabline = {
      nvimBufferline = {
        enable = true;
        setupOpts.options = {
          show_buffer_icons = true;
          show_buffer_close_icons = false;
          show_close_icon = false;
          show_tab_indicators = true;
          diagnostics = "nvim_lsp";
          always_show_bufferline = true;
          name_formatter = null;
          numbers = "none";
        };
      };
    };

    ui = {
      borders.enable = true;
      noice.enable = true;
      colorizer.enable = true;
      modes-nvim.enable = true;
      illuminate.enable = true;
    };

    visuals = {
      nvim-scrollbar.enable = true;
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      highlight-undo.enable = true;

      # requires treesitter
      blink-indent.enable = false;
      indent-blankline = {
        enable = true;
        setupOpts.scope.enabled = true;
      };
    };

    git.gitsigns.enable = true;

    comments.comment-nvim.enable = true;

    statusline.lualine = {
      enable = true;
      theme = "auto";
    };

    autopairs.nvim-autopairs.enable = true;
  };
}
