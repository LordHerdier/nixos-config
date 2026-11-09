# home/modules/nvf/10-theme.nix
#
# `theme` is the resolved my.theme palette, passed in through
# extraSpecialArgs by ./default.nix -- nvf evaluates its own module
# system, so home-manager's config is not reachable from here.
#
# Nightfox addresses colors as base/bright pairs, which is exactly the
# ANSI 16 split the palette already carries.

{
  pkgs,
  theme,
  themeRuntime,
  paletteLua,
  ...
}:

let
  # Followed palettes: neovim watches ${themeRuntime} for `theme-set`
  # repointing `active`, and re-applies. Pinned ones (themeRuntime null)
  # just use the palette they were built with. The built-in one is also
  # the fallback when the active file is missing or does not parse.
  watch = themeRuntime != null;
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
      local builtin = (function()
      ${paletteLua theme}
      end)()

      local function apply(t)
        require("nightfox").setup({
          palettes = { all = t.palette },
          options = {
            transparent    = true,
            terminal_colors = false,
            -- dim_inactive   = true,
          },
        })
        vim.cmd("colorscheme nightfox")
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = t.border, bg = "NONE" });
      end

    ''
    + (
      if !watch then
        "apply(builtin)\n"
      else
        ''

          -- Follow theme-set. It replaces the `active` symlink with a rename,
          -- which shows up as an event for "active" on the directory.
          local dir = "${themeRuntime}"
          local function reload()
            local ok, t = pcall(dofile, dir .. "/active/nvim.lua")
            apply(ok and type(t) == "table" and t or builtin)
          end
          reload()
          local watcher = vim.uv.new_fs_event()
          if watcher then
            watcher:start(dir, {}, vim.schedule_wrap(function(err, name)
              if not err and name == "active" then reload() end
            end))
          end
        ''
    );
  };
}
