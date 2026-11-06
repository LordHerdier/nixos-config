# home/modules/nvf/plugins/80-devshell.nix
#
# Devshell integration, so language servers see the toolchain a project
# pins rather than whatever happens to be on PATH.
#
# nix-develop.nvim provides :NixDevelop / :NixShell / :FlakeShell, which
# swap the running nvim's environment into the devshell -- LSPs started
# afterwards inherit it. No daemon or per-project file needed.
#
# `vim.utility.direnv` (direnv.vim) syncs the environment on directory
# change, so a project's `.envrc` (`use flake`) loads its devshell
# automatically. direnv itself is set up in home/modules/direnv.nix.

{ ... }:

{
  config.vim.utility.nix-develop.enable = true;
  config.vim.utility.direnv.enable = true;
}
