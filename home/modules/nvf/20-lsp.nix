# home/modules/nvf/20-lsp.nix

{ lib, pkgs, ... }:

{
  config.vim = {
    autocomplete.nvim-cmp.enable = true;

    # Without it nvf registers no luasnip cmp source, and LSP snippet
    # completions insert literal $1/$0 placeholders.
    snippets.luasnip.enable = true;

    # nixpkgs asm-lsp 0.10.1 and neocmakelsp 0.11.2 fail to build (missing
    # zstd / pkg-config+oniguruma for their -sys crates), as does gersemi (sqlite). The nvf presets
    # hardcode pkgs.<name>, so override each server's cmd. Drop once fixed
    # upstream.
    lsp.servers = {
      asm-lsp.cmd = lib.mkForce [
        (lib.getExe (
          pkgs.asm-lsp.overrideAttrs (old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.zstd ];
          })
        ))
      ];
      neocmakelsp.cmd = lib.mkForce [
        (lib.getExe (
          pkgs.neocmakelsp.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
            buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.oniguruma ];
          })
        ))
        "stdio"
      ];
    };

    formatter.conform-nvim.setupOpts.formatters.gersemi.command = lib.mkForce (
      lib.getExe (
        pkgs.gersemi.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.sqlite ];
        })
      )
    );

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
