# home/modules/nvf/41-nvim-tree.nix

{ lib, ... }:

{
  config.vim = {
    filetree.nvimTree = {
      enable = true;
      openOnSetup = false;
      mappings.toggle = "<leader>e";

      setupOpts.on_attach = lib.generators.mkLuaInline "__nvimtree_on_attach";
    };

    luaConfigRC.nvimtree-on-attach = # lua
      ''
        function __nvimtree_on_attach(bufnr)
          local api = require("nvim-tree.api")

          local function map(key, fn, desc)
            vim.keymap.set("n", key, fn, {
              buffer = bufnr, noremap = true, silent = true, nowait = true, desc = "nvim-tree: " .. desc,
            })
          end

          -- Colemak navigation (u/e = up/down cursor, U/E = tree structure)
          map("u",     "k",                              "Cursor Up")
          map("e",     "j",                              "Cursor Down")
          map("U",     api.node.navigate.parent,         "Parent Directory")
          map("E",     api.node.navigate.sibling.next,   "Next Sibling")
          map("h",     api.node.navigate.parent_close,   "Close Directory")

          -- Open / edit
          map("i",     api.node.open.edit,              "Open")
          map("<CR>",  api.node.open.edit,              "Open")
          map("o",     api.node.open.edit,              "Open")
          map("<2-LeftMouse>", api.node.open.edit,      "Open")
          map("v",     api.node.open.vertical,          "Open Vertical Split")
          map("s",     api.node.open.horizontal,        "Open Horizontal Split")
          map("<Tab>", api.node.open.preview,           "Preview")

          -- File operations
          map("a",     api.fs.create,                   "Create File/Dir")
          map("d",     api.fs.remove,                   "Delete")
          map("r",     api.fs.rename,                   "Rename")
          map("R",     api.fs.rename_full,              "Rename (Full Path)")
          map("x",     api.fs.cut,                      "Cut")
          map("c",     api.fs.copy.node,                "Copy")
          map("p",     api.fs.paste,                    "Paste")
          map("y",     api.fs.copy.filename,            "Copy Filename")
          map("Y",     api.fs.copy.relative_path,       "Copy Relative Path")
          map("gy",    api.fs.copy.absolute_path,       "Copy Absolute Path")

          -- Tree controls
          map("q",     api.tree.close,                  "Close Tree")
          map("W",     api.tree.collapse_all,           "Collapse All")
          map("<C-e>", api.tree.expand_all,             "Expand All")
          map("<C-r>", api.tree.reload,                 "Refresh")
          map("?",     api.tree.toggle_help,            "Help")

          -- Filters
          map(".",     api.tree.toggle_hidden_filter,           "Toggle Dotfiles")
          map("I",     api.tree.toggle_gitignore_filter,        "Toggle Git Ignore")
        end
      '';
  };
}
