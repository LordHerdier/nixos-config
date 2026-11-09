# home/modules/nvf/plugins/98-neotest.nix
#
# Test runner: run the test under the cursor, the file, or the suite, with
# results in the sign column and failure output in a float.
#
# nvf has no neotest module, so this uses extraPlugins; `after` makes sure
# the adapters load before neotest's setup. plenary and nvim-treesitter
# are already start plugins.
#
# Adapters match the languages in ../20-lsp.nix; nixpkgs has more
# (neotest-bash, -nix, -go, -rust, -jest, -gtest, ...).

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

          -- Skip an adapter that fails to load rather than abort setup.
          local function add(name, opts)
            local ok, adapter = pcall(require, name)
            if not ok then
              return
            end
            table.insert(adapters, opts and adapter(opts) or adapter)
          end

          -- justMyCode=false: honour breakpoints in library code under dap.
          add("neotest-python", { dap = { justMyCode = false } })
          add("neotest-plenary")
          add("neotest-vitest")
          add("neotest-ctest")

          require("neotest").setup({
            adapters = adapters,
            quickfix = {
              -- Trouble is the diagnostics UI; leave quickfix alone.
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
      # Uses the DAP adapters from ../20-lsp.nix.
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
