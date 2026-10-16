# home/modules/nvf/plugins/80-devshell.nix
#
# Devshell integration, so language servers see the toolchain a project
# pins rather than whatever happens to be on PATH.
#
# nix-develop.nvim provides :NixDevelop / :NixShell / :FlakeShell, which
# swap the running nvim's environment into the devshell -- LSPs started
# afterwards inherit it. No daemon or per-project file needed.
#
# The automatic alternative is `vim.utility.direnv.enable` (direnv.vim),
# which syncs the environment on directory change. It is intentionally left
# off: direnv is not installed on this system and nothing here sets
# `programs.direnv.enable`, so the plugin would have no binary to talk to.
# Enable it here once direnv is set up, if the .envrc workflow is wanted.

{ ... }:

{
  config.vim.utility.nix-develop.enable = true;
}
