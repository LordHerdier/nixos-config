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
