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

    # nvim-ufo (plugins/95-folds.nix) computes folds itself, but it still
    # honours these. Without the high foldlevel every buffer would open
    # fully collapsed, which is the usual first impression that ufo is
    # "broken". foldcolumn stays off to keep the gutter as sparse as the
    # rest of the UI -- ufo still renders the folded-line virtual text.
    foldenable = true;
    foldlevel = 99;
    foldlevelstart = 99;
    foldcolumn = "0";
  };

  config.vim = {
    viAlias = true;
    vimAlias = true;

    # Case-insensitive search until the pattern contains a capital.
    # nvf's default is "sensitive".
    searchCase = "smart";

    # Persistent undo. Off by default in nvf, so undo history currently dies
    # with the session; paired with the undotree visualiser in
    # plugins/99-undotree.nix. Stored under stdpath('state')/undo.
    undoFile.enable = true;

    # Route the unnamed register through the system clipboard. wl-clipboard
    # is already installed (home/modules/packages.nix), but neovim only uses
    # it for the explicit "+ / "* registers unless told otherwise -- until
    # now a plain `y` did not leave neovim.
    #
    # Note this cuts both ways: with unnamedplus, deletes and changes also
    # overwrite the system clipboard. Drop to "unnamed", or remove this, if
    # that turns out to be more annoying than useful.
    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers.wl-copy.enable = true;
    };
  };

  # WSL has no reachable Wayland compositor from nvim's point of view (or
  # WAYLAND_DISPLAY is unset), so the wl-copy provider fails with "cannot
  # connect to the wayland backend". Talk to the Windows clipboard instead:
  # clip.exe for copy, powershell Get-Clipboard for paste. Detected at
  # runtime so the same build works on the native NixOS hosts.
  config.vim.luaConfigRC.wsl-clipboard = # lua
    ''
      if vim.fn.has("wsl") == 1 then
        local ps = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
        local clip = "/mnt/c/Windows/System32/clip.exe"
        local paste = {
          ps, "-NoProfile", "-NoLogo", "-NonInteractive", "-Command",
          "[Console]::OutputEncoding=[Text.Encoding]::UTF8;" ..
          "[Console]::Out.Write((Get-Clipboard -Raw))",
        }
        vim.g.clipboard = {
          name = "wsl-clip",
          copy = { ["+"] = { clip }, ["*"] = { clip } },
          paste = { ["+"] = paste, ["*"] = paste },
          cache_enabled = 0,
        }
      end
    '';

  config.vim.luaConfigRC.pane-borders = # lua
    ''
      -- Global statusline, so splits do not each get their own bar. Inside
      -- tmux this is overridden to 0 by vim-tpipeline, which moves the bar
      -- into the tmux status line instead (see plugins/96-tpipeline.nix).
      vim.opt.laststatus = 3
      vim.opt.fillchars:append("vert:│,horiz:─,horizup:┴,horizdown:┬,vertleft:┤,vertright:├,verthoriz:┼")
    '';
}
