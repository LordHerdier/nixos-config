# home/modules/nvf/plugins/80-devshell.nix
#
# Devshell integration, so language servers see the project's toolchain.
#
# nix-develop.nvim: :NixDevelop / :NixShell / :FlakeShell swap the running
# nvim's environment into the devshell; LSPs started afterwards inherit it.
# direnv.vim loads a project's `.envrc` on directory change (direnv itself
# is set up in home/modules/direnv.nix).

{ ... }:

{
  config.vim.utility.nix-develop.enable = true;
  config.vim.utility.direnv.enable = true;
}
