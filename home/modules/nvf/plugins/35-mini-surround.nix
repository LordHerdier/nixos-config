# home/modules/nvf/plugins/35-mini-surround.nix

{ ... }:

{
  config.vim.mini.surround = {
    enable = true;

    setupOpts = {
      mappings = {
        add = "sa"; # Add surrounding in Normal and Visual modes
        delete = "sd"; # Delete surrounding
        find = "sf"; # Find surrounding (to the right)
        find_left = "sF"; # Find surrounding (to the left)
        highlight = "sh"; # Highlight surrounding
        replace = "sr"; # Replace surrounding
        update_n_lines = "sn"; # Update `n_lines`
      };
    };
  };
}
