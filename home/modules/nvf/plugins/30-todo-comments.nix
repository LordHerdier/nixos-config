# home/modules/nvf/plugins/30-todo-comments.nix

{ ... }:

{
  config.vim = {
    notes.todo-comments.enable = true;

    # Telescope integration keymaps
    keymaps = [
      {
        mode = "n";
        key = "<leader>tt";
        action = ":TodoTelescope<CR>";
        desc = "Search TODOs";
      }
      {
        mode = "n";
        key = "<leader>xt";
        action = ":Trouble todo<CR>";
        desc = "TODOs in Trouble";
      }
    ];
  };
}
