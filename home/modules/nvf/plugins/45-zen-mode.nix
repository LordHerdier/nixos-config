# home/modules/nvf/plugins/45-zen-mode.nix

{ pkgs, ... }:

{
  config.vim.extraPlugins.zen-mode = {
    package = pkgs.vimPlugins.zen-mode-nvim;
  };

  config.vim.extraPlugins.twilight = {
    package = pkgs.vimPlugins.twilight-nvim;
  };

  config.vim.extraPlugins.vim-pencil = {
    package = pkgs.vimPlugins.vim-pencil;
  };

  config.vim.luaConfigRC.zen-mode = # lua
    ''
      require("twilight").setup({})

      -- <leader>Z sets this so twilight + pencil only accompany that entry point
      local writing_mode = false

      -- State stashed on open and put back on close.
      local saved = {}

      local function word_count()
        local wc = vim.fn.wordcount()
        return (wc.visual_words or wc.words) .. " words"
      end

      -- Quiet everything that would pop up or draw outside the text.
      local function hide_chrome(buf)
        saved.notify = vim.notify
        vim.notify = function() end
        pcall(function() require("noice").disable() end)

        saved.showtabline = vim.o.showtabline
        vim.o.showtabline = 0
        vim.cmd("silent! ScrollbarHide")
        pcall(function() require("ibl").setup_buffer(buf, { enabled = false }) end)
        pcall(function() require("illuminate").pause_buf() end)

        -- zen-mode hides the statusline (laststatus=0); keep a bare one with
        -- just the word count instead of lualine's usual sections.
        saved.laststatus = vim.o.laststatus
        vim.o.laststatus = 2
        local ok, lualine = pcall(require, "lualine")
        if ok then
          saved.lualine = lualine.get_config()
          local cfg = vim.deepcopy(saved.lualine)
          -- lualine merges over its defaults, so empty sections must be explicit
          cfg.sections = {
            lualine_a = {}, lualine_b = {}, lualine_c = { word_count },
            lualine_x = {}, lualine_y = {}, lualine_z = {},
          }
          cfg.inactive_sections = {
            lualine_a = {}, lualine_b = {}, lualine_c = {},
            lualine_x = {}, lualine_y = {}, lualine_z = {},
          }
          lualine.setup(cfg)
        end
      end

      local function show_chrome(buf)
        if saved.notify then vim.notify = saved.notify end
        pcall(function() require("noice").enable() end)

        if saved.showtabline then vim.o.showtabline = saved.showtabline end
        vim.cmd("silent! ScrollbarShow")
        pcall(function() require("ibl").setup_buffer(buf, { enabled = true }) end)
        pcall(function() require("illuminate").resume_buf() end)

        if saved.lualine then require("lualine").setup(saved.lualine) end
        -- lualine's setup resets laststatus, so restore it afterwards
        if saved.laststatus then vim.o.laststatus = saved.laststatus end
        saved = {}
      end

      require("zen-mode").setup({
        on_open = function()
          if writing_mode then
            vim.cmd("TwilightEnable")
            vim.cmd("PencilSoft")
            local buf = vim.api.nvim_get_current_buf()
            vim.treesitter.stop(buf)
            require("cmp").setup.buffer({ enabled = false })
            vim.diagnostic.enable(false, { bufnr = buf })
            hide_chrome(buf)
          end
        end,
        on_close = function()
          if writing_mode then
            vim.cmd("TwilightDisable")
            vim.cmd("PencilOff")
            local buf = vim.api.nvim_get_current_buf()
            pcall(vim.treesitter.start, buf)
            require("cmp").setup.buffer({ enabled = true })
            vim.diagnostic.enable(true, { bufnr = buf })
            show_chrome(buf)
            -- PencilOff leaves its buffer-local movement remaps behind (it
            -- also remaps colemak e/u via Mapkey), so clear them ourselves.
            for _, mode in ipairs({ "n", "v" }) do
              for _, key in ipairs({ "e", "u", "j", "k", "gj", "gk", "g0", "g$", "0", "$" }) do
                pcall(vim.keymap.del, mode, key, { buffer = buf })
              end
            end
            writing_mode = false
          end
        end,
        window = {
          width = 0.70,
          height = 1,
          options = {
            signcolumn = "no",
            cursorline = false, 
            number = false,
            relativenumber = false,
          },
        },
      })

      vim.api.nvim_create_user_command("WritingMode", function()
        -- Only flag on open; on close on_close still needs it set.
        if not require("zen-mode.view").is_open() then
          writing_mode = true
        end
        require("zen-mode").toggle()
      end, {})
    '';

  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>z";
      action = "<cmd>ZenMode<CR>";
      desc = "Toggle Zen Mode";
    }
    {
      mode = "n";
      key = "<leader>Z";
      action = "<cmd>WritingMode<CR>";
      desc = "Toggle Zen + Twilight + Pencil (distractions off)";
    }
  ];
}
