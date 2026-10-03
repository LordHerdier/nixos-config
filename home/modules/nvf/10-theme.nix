# home/modules/nvf/10-theme.nix
#
# `theme` is the resolved my.theme palette, passed in through
# extraSpecialArgs by ./default.nix -- nvf evaluates its own module
# system, so home-manager's config is not reachable from here.
#
# Nightfox addresses colors as base/bright pairs, which is exactly the
# ANSI 16 split the palette already carries.

{ pkgs, theme, ... }:

let
  p = theme.palette;
  r = theme.roles;
in
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
              black    = "${p.black}",
              red      = { base = "${p.red}", bright = "${p.brightRed}" },
              green    = { base = "${p.green}", bright = "${p.brightGreen}" },
              yellow   = { base = "${p.yellow}", bright = "${p.brightYellow}" },
              blue     = { base = "${p.blue}", bright = "${p.brightBlue}" },
              magenta  = { base = "${p.magenta}", bright = "${p.brightMagenta}" },
              cyan     = { base = "${p.cyan}", bright = "${p.brightCyan}" },
              white    = { base = "${p.white}", bright = "${p.brightWhite}" },
              bg0      = "${p.bg}",
              fg1      = "${p.fg}",
            },
          },
          options = {
            transparent    = true,
            terminal_colors = false,
            -- dim_inactive   = true,
          },
        })
        vim.cmd("colorscheme nightfox")
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = "${r.border}", bg = "NONE" });
      '';
  };
}
