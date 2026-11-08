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

    # nvim-ufo (plugins/95-folds.nix) still honours these. Without the
    # high foldlevel every buffer opens fully collapsed. No foldcolumn;
    # ufo still renders the folded-line virtual text.
    foldenable = true;
    foldlevel = 99;
    foldlevelstart = 99;
    foldcolumn = "0";
  };

  config.vim = {
    viAlias = true;
    vimAlias = true;

    # Case-insensitive until the pattern has a capital (nvf default:
    # "sensitive").
    searchCase = "smart";

    # Persistent undo (off by default in nvf), under stdpath('state')/undo.
    # Pairs with plugins/99-undotree.nix.
    undoFile.enable = true;

    # Unnamed register goes through the system clipboard, so a plain `y`
    # leaves neovim. Cuts both ways: deletes and changes overwrite the
    # clipboard too.
    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers.wl-copy.enable = true;
    };
  };

  # On WSL the wl-copy provider fails ("cannot connect to the wayland
  # backend"), so use the Windows clipboard: clip.exe to copy, powershell
  # Get-Clipboard to paste. Detected at runtime, so one build serves all
  # hosts.
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
      -- Global statusline. Inside tmux, vim-tpipeline sets this to 0 and
      -- moves the bar into tmux's (see plugins/96-tpipeline.nix).
      vim.opt.laststatus = 3
      vim.opt.fillchars:append("vert:│,horiz:─,horizup:┴,horizdown:┬,vertleft:┤,vertright:├,verthoriz:┼")
    '';
}
