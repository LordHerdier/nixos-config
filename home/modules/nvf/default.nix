# home/modules/nvf/default.nix

{ pkgs, inputs, ... }:

let
  nvfConfig = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [
      ./00-options.nix
      ./10-theme.nix
      ./20-lsp.nix
      ./30-keymaps.nix
    ];
  };
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "nvf" ''
      exec ${nvfConfig.neovim}/bin/nvim "$@"
    '')
  ];
}
