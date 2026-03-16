# home/modules/nvf/plugins/20-telescope.nix

{ pkgs, ... }:

{
  config.vim.telescope = {
    enable = true;

    extensions = [
      {
        name = "fzf";
        packages = [ pkgs.vimPlugins.telescope-fzf-native-nvim ];
        setup = {
          fzf = {
            fuzzy = true;
          };
        };
      }
    ];

    mappings = {
      buffers = "fb";
      diagnostics = "fld";
      findFiles = "ff";
      findProjects = "fp";
      gitBranches = "fvb";
      gitBufferCommits = "fvcb";
      gitCommits = "fvcw";
      gitFiles = "fvf";
      gitStash = "fvx";
      gitStatus = "fvs";
      helpTags = "fh";
      liveGrep = "fg";
      lspDefinitions = "flD";
      lspDocumentSymbols = "flsb";
      lspImplementations = "fli";
      lspReferences = "flr";
      lspTypeDefinitions = "flt";
      lspWorkspaceSymbols = "flsw";
      open = "ft";
      resume = "fs";
    };
  };
}
