# home/modules/nvf/plugins/05-neo-tree.nix

{ lib, ... }:

{
  # Disable nvim-tree
  config.vim.filetree.nvimTree.enable = lib.mkForce false;

  config.vim.filetree.neo-tree = {
    enable = true;

    setupOpts = {
      close_if_last_window = true;
      enable_git_status = true;
      enable_diagnostics = true;
      git_status_async = true;

      filesystem = {
        follow_current_file.enabled = true;
        hijack_netrw_behavior = "open_default";
        use_libuv_file_watcher = true;
        filtered_items = {
          visible = false;
          hide_dotfiles = false;
          hide_gitignored = false;
        };
      };

      window = {
        position = "left";
        width = 35;

        mappings = {
          # Colemak tree navigation
          # u/e = cursor up/down, i = open (right), n = collapse (left)
          # These must be explicit so neo-tree's defaults don't shadow globals
          "u" = lib.generators.mkLuaInline ''function() vim.cmd("normal! k") end'';
          "e" = lib.generators.mkLuaInline ''function() vim.cmd("normal! j") end'';
          "U" = lib.generators.mkLuaInline ''function() vim.cmd("normal! 5k") end'';
          "E" = lib.generators.mkLuaInline ''function() vim.cmd("normal! 5j") end'';
          "i" = "open"; # right = enter node
          "n" = "close_node"; # left  = collapse
          "I" = "show_file_details";
          "<CR>" = "open";
          "o" = "open";
          "<2-LeftMouse>" = "open";
          "s" = "open_vsplit";
          "S" = "open_split";
          "t" = "open_tabnew";
          "<Tab>" = lib.generators.mkLuaInline ''
            {
                        "toggle_preview",
                        config = { use_float = true, use_snacks_image = true },
                      }'';

          # Navigation (continued)
          "h" = "close_node"; # also keep h for collapse
          "z" = "close_all_nodes";
          "<bs>" = "navigate_up";
          "." = "set_root";

          # File operations
          "a" = lib.generators.mkLuaInline ''
            {
                        "add",
                        config = { show_path = "relative" },
                      }'';
          "A" = "add_directory";
          "d" = "delete";
          "r" = "rename";
          "b" = "rename_basename";
          "y" = "copy_to_clipboard";
          "x" = "cut_to_clipboard";
          "p" = "paste_from_clipboard";
          "c" = "copy";
          "m" = "move";

          # Tree controls
          "q" = "close_window";
          "R" = "refresh";
          "?" = "show_help";
          "<" = "prev_source";
          ">" = "next_source";

          # Filters
          "H" = "toggle_hidden";
          "/" = "fuzzy_finder";
          "f" = "filter_on_submit";
          "<C-x>" = "clear_filter";

          # Git navigation
          "[g" = "prev_git_modified";
          "]g" = "next_git_modified";
        };
      };

      buffers = {
        follow_current_file.enabled = true;
        group_empty_dirs = true;
        show_unloaded = true;
      };

      git_status.window.position = "float";
    };
  };

  # Toggle keymap
  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
      desc = "Toggle file tree";
    }
    {
      mode = "n";
      key = "<leader>ge";
      action = "<cmd>Neotree git_status<CR>";
      desc = "Git status tree";
    }
    {
      mode = "n";
      key = "<leader>be";
      action = "<cmd>Neotree buffers<CR>";
      desc = "Buffer tree";
    }
  ];
}
