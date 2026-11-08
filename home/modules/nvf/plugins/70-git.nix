# home/modules/nvf/plugins/70-git.nix
#
# Git beyond gitsigns' gutter marks: a status/commit UI (neogit), diff and
# history review (diffview), and conflict resolution (git-conflict).
#
# Not `vim.git.enable`: that suite also pulls in vim-fugitive, hunk-nvim,
# gitlinker and octo-nvim (which wants `gh`).
#
# Namespaces: gitsigns owns <leader>h* and [c/]c, neo-tree <leader>ge,
# this file <leader>g* and <leader>c*.

{ ... }:

{
  config.vim.git.neogit = {
    enable = true;
    # Defaults: <leader>gs status, <leader>gc commit,
    #           <leader>gp pull,   <leader>gP push
  };

  config.vim.utility.diffview-nvim.enable = true;

  config.vim.git.git-conflict = {
    enable = true;

    # nvf's defaults are backwards ("]x" = prev, "[x" = next).
    mappings = {
      prevConflict = "[x";
      nextConflict = "]x";
      # Unchanged: <leader>co ours, <leader>ct theirs,
      #            <leader>cb both, <leader>c0 none
    };
  };

  # diffview has no global mappings; nvf lazy-loads it on these commands.
  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<CR>";
      desc = "Diff working tree";
    }
    {
      mode = "n";
      key = "<leader>gD";
      action = "<cmd>DiffviewClose<CR>";
      desc = "Close diffview";
    }
    {
      mode = "n";
      key = "<leader>gh";
      action = "<cmd>DiffviewFileHistory<CR>";
      desc = "Repo file history";
    }
    {
      mode = "n";
      key = "<leader>gf";
      action = "<cmd>DiffviewFileHistory %<CR>";
      desc = "Current file history";
    }
  ];
}
