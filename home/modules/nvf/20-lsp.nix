# home/modules/nvf/20-lsp.nix

{ ... }:

{
  config.vim = {
    autocomplete.nvim-cmp.enable = true;

    # Without it nvf registers no luasnip cmp source, and LSP snippet
    # completions insert literal $1/$0 placeholders.
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

      # Per-language debug adapters *and* launch configurations (bare
      # nvim-dap presets only register adapters). Of the languages below,
      # python (debugpy) and clang (lldb) have DAP support.
      enableDAP = true;

      assembly.enable = true;
      bash.enable = true;
      # cpplint (which once broke the build) is only pulled in if named in
      # clang.extraDiagnostics.types; the default is clang-tidy only.
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
