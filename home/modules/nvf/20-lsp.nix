# home/modules/nvf/20-lsp.nix

{ ... }:

{
  config.vim = {
    autocomplete.nvim-cmp.enable = true;

    lsp = {
      enable = true;

      formatOnSave = true;
      lspkind.enable = false;
      lightbulb.enable = true;
      lspsaga.enable = false;
      trouble.enable = true;
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      assembly.enable = true;
      bash.enable = true;
      # clang pulls in cpplint, which fails its test suite on the current
      # nixpkgs (cpplint-2.0.2 check phase asserts empty stderr, but a newer
      # Python emits a codecs.open() DeprecationWarning -> 17 test failures).
      # Disabled to unblock rebuilds; re-enable once nixpkgs fixes cpplint.
      # clang.enable = true;
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
