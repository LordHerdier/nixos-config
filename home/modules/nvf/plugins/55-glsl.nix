# home/modules/nvf/plugins/55-glsl.nix
#
# Live shader preview: glslViewer hot-reloads the file on save, so the
# editor only needs to launch/stop it.

{ pkgs, ... }:

{
  config.vim = {
    # Treesitter highlighting for .frag/.vert/.glsl
    treesitter.grammars = [ pkgs.vimPlugins.nvim-treesitter.builtGrammars.glsl ];

    # GLSL language server
    lsp.servers.glsl_analyzer = {
      cmd = [ "${pkgs.glsl_analyzer}/bin/glsl_analyzer" ];
      filetypes = [ "glsl" ];
    };

    extraPackages = [ pkgs.glslviewer ];

    luaConfigRC.glsl-preview = # lua
      ''
        vim.filetype.add({ extension = { frag = "glsl", vert = "glsl", glsl = "glsl" } })

        local job
        vim.api.nvim_create_user_command("ShaderPreview", function()
          if job then vim.fn.jobstop(job); job = nil; return end
          job = vim.fn.jobstart({ "glslViewer", vim.fn.expand("%:p"), "-w", "500", "-h", "500" },
            { on_exit = function() job = nil end })
        end, {})
        vim.api.nvim_create_autocmd("VimLeavePre", {
          callback = function() if job then vim.fn.jobstop(job) end end,
        })
      '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>sp";
        action = "<cmd>ShaderPreview<CR>";
        desc = "Toggle shader preview";
      }
    ];
  };
}
