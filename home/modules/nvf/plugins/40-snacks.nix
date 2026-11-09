# home/modules/nvf/plugins/40-snacks.nix

{ ... }:

{
  config.vim = {
    utility.snacks-nvim = {
      enable = true;

      setupOpts = {
        terminal.enabled = true;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<C-_>"; # C-/
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        desc = "Toggle terminal";
      }
      {
        mode = "t";
        key = "<C-_>"; # C-/
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        desc = "Toggle terminal";
      }
    ];
  };
}
