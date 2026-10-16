# home/modules/nvf/plugins/98-neotest.nix
#
# Test runner: run the test under the cursor, the file, or the suite, with
# results in the sign column and failure output in a float.
#
# nvf has no neotest module -- there is nothing under modules/plugins for it
# at all -- so this goes in through extraPlugins, the same route as
# 45-zen-mode.nix and 50-peek.nix. extraPlugins is a DAG, so `after` is what
# guarantees the adapters are on the runtimepath before neotest's setup runs.
#
# neotest needs plenary and nvim-treesitter too; both are already start
# plugins (plenary via neogit/diffview/telescope), so they are not repeated
# here.
#
# Adapters are matched to the languages enabled in ../20-lsp.nix. nixpkgs
# also carries neotest-bash, neotest-nix, neotest-go, neotest-rust,
# neotest-jest, neotest-gtest and others if the set needs widening.

{ pkgs, ... }:

{
  config.vim.extraPlugins = {
    nvim-nio.package = pkgs.vimPlugins.nvim-nio;

    neotest-python.package = pkgs.vimPlugins.neotest-python;
    neotest-plenary.package = pkgs.vimPlugins.neotest-plenary;
    neotest-vitest.package = pkgs.vimPlugins.neotest-vitest;
    neotest-ctest.package = pkgs.vimPlugins.neotest-ctest;

    neotest = {
      package = pkgs.vimPlugins.neotest;

      after = [
        "nvim-nio"
        "neotest-python"
        "neotest-plenary"
        "neotest-vitest"
        "neotest-ctest"
      ];

      setup = # lua
        ''
          local adapters = {}

          -- Skip an adapter rather than aborting the whole setup if it fails
          -- to load; one broken adapter would otherwise take neotest with it.
          local function add(name, opts)
            local ok, adapter = pcall(require, name)
            if not ok then
              return
            end
            table.insert(adapters, opts and adapter(opts) or adapter)
          end

          -- justMyCode=false so breakpoints inside library code are honoured
          -- when a test is debugged through nvim-dap (see 55-dap.nix).
          add("neotest-python", { dap = { justMyCode = false } })
          add("neotest-plenary")
          add("neotest-vitest")
          add("neotest-ctest")

          require("neotest").setup({
            adapters = adapters,
            quickfix = {
              -- Trouble is the diagnostics UI here; don't also hijack the
              -- quickfix list on every run.
              enabled = false,
            },
          })
        '';
    };
  };

  # <leader>T* rather than <leader>t*: todo-comments already owns <leader>tt
  # and gitsigns owns <leader>tb / <leader>td.
  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>Tr";
      action = "<cmd>lua require('neotest').run.run()<CR>";
      desc = "Run nearest test";
    }
    {
      mode = "n";
      key = "<leader>Tf";
      action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>";
      desc = "Run tests in file";
    }
    {
      mode = "n";
      key = "<leader>Tl";
      action = "<cmd>lua require('neotest').run.run_last()<CR>";
      desc = "Re-run last test";
    }
    {
      mode = "n";
      key = "<leader>TS";
      action = "<cmd>lua require('neotest').run.stop()<CR>";
      desc = "Stop running test";
    }
    {
      # Runs the nearest test under nvim-dap, reusing the adapters from
      # ../20-lsp.nix rather than a separate debug configuration.
      mode = "n";
      key = "<leader>Td";
      action = "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<CR>";
      desc = "Debug nearest test";
    }
    {
      mode = "n";
      key = "<leader>Ts";
      action = "<cmd>lua require('neotest').summary.toggle()<CR>";
      desc = "Toggle test summary";
    }
    {
      mode = "n";
      key = "<leader>To";
      action = "<cmd>lua require('neotest').output.open({ enter = true })<CR>";
      desc = "Show test output";
    }
    {
      mode = "n";
      key = "<leader>TO";
      action = "<cmd>lua require('neotest').output_panel.toggle()<CR>";
      desc = "Toggle test output panel";
    }
  ];
}
