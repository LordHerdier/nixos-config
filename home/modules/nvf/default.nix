# home/modules/nvf/default.nix
{
  pkgs,
  inputs,
  ...
}:

let
  nvfConfig = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [
      ./00-options.nix
      ./10-theme.nix
      ./20-lsp.nix
      ./90-keymaps.nix
      ./plugins
    ];
  };
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "nvim" ''
      exec ${nvfConfig.neovim}/bin/nvim "$@"
    '')
  ];
}
