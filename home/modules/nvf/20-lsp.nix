# home/modules/nvf/20-lsp.nix

{ ... }:

{
  config.vim = {
    autocomplete.nvim-cmp.enable = true;

    # Gates cmp's snippet support: nvf only registers the `luasnip` source and
    # the cmp-luasnip plugin when this is on, so without it LSP completions
    # that return snippet text insert literal $1/$0 placeholders instead of
    # jumpable fields. Pulls friendly-snippets by default.
    snippets.luasnip.enable = true;

    lsp = {
      enable = true;

      formatOnSave = true;
      inlayHints.enable = true;
      # Argument hints in a float while typing a call.
      lspSignature.enable = true;
      lspkind.enable = false;
      lightbulb.enable = true;
      lspsaga.enable = false;
      trouble.enable = true;
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      # Per-language debug adapters *and* their launch configurations. The bare
      # debugger.nvim-dap presets only register an adapter; this is what also
      # fills in debugger.nvim-dap.configurations.<filetype>. Of the languages
      # enabled below, python (debugpy) and clang (lldb) carry DAP support.
      enableDAP = true;

      assembly.enable = true;
      bash.enable = true;
      # Previously disabled over a cpplint build failure. That no longer
      # applies: clang's extraDiagnostics.types defaults to ["clangtidy"],
      # and the cpplint preset is only switched on by naming it there, so
      # pkgs.cpplint is never evaluated. Brings clangd, clang-format,
      # clang-tidy, and -- via enableDAP above -- lldb for C/C++ debugging.
      clang.enable = true;
      cmake.enable = true;
      css.enable = true;
      html.enable = true;
      json.enable = true;
      lua.enable = true;
      make.enable = true;
      markdown.enable = true;
      nix = {
        enable = true;
        format.type = [ "nixfmt" ];
      };
      python.enable = true;
      qml.enable = true;
      svelte.enable = true;
      toml.enable = true;
      typescript.enable = true;
    };
  };
}
