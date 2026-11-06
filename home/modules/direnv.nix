# home/modules/direnv.nix
#
# direnv + nix-direnv: `use flake` in a project's .envrc loads its devshell
# (cached, and protected from garbage collection) on cd. nvim picks the
# environment up through vim.utility.direnv (see nvf/plugins/80-devshell.nix).

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
