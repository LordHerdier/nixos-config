# home/modules/nvf/00-options.nix

{ ... }:

{
  config.vim.options = {
    number = true;
    relativenumber = true;
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    wrap = false;
  };

  config.vim = {
    viAlias = true;
    vimAlias = true;
  };

  config.vim.luaConfigRC.pane-borders = # lua
    ''
      vim.opt.laststatus = 3 -- global statusline (avoids double bar)
      vim.opt.fillchars:append("vert:│,horiz:─,horizup:┴,horizdown:┬,vertleft:┤,vertright:├,verthoriz:┼")
    '';
}
