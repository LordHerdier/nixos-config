# home/modules/nvf/plugins/70-git.nix
#
# Git beyond gitsigns' gutter marks: a status/commit UI (neogit), diff and
# history review (diffview), and conflict resolution (git-conflict).
#
# Deliberately NOT setting `vim.git.enable`, which is a suite switch that
# would also drag in vim-fugitive, hunk-nvim, gitlinker and octo-nvim (the
# last of which wants the `gh` CLI). The pieces are enabled individually.
#
# Namespaces in use, none of which collide: gitsigns owns <leader>h* and
# [c/]c, neo-tree owns <leader>ge, this file adds <leader>g* and <leader>c*.

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

    # nvf's defaults have these two backwards ("]x" = prev, "[x" = next).
    # Restore the usual vim direction: [ goes back, ] goes forward.
    mappings = {
      prevConflict = "[x";
      nextConflict = "]x";
      # Unchanged: <leader>co ours, <leader>ct theirs,
      #            <leader>cb both, <leader>c0 none
    };
  };

  # diffview ships no mappings of its own; these are the commands nvf
  # lazy-loads it on.
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
