# home/modules/nvf/plugins/75-project.nix
#
# Project awareness and session persistence.

{ ... }:

{
  # nvf only creates the `fp` telescope mapping (./20-telescope.nix) and
  # loads the `projects` extension when this is enabled.
  config.vim.projects.project-nvim = {
    enable = true;

    setupOpts = {
      # (nvf's default.) Only change cwd on request -- `fp` or
      # :ProjectRoot -- not on every buffer switch.
      manual_mode = true;
      detection_methods = [
        "lsp"
        "pattern"
      ];
    };
  };

  # <leader>qs loads the session for the cwd, <leader>ql picks one.
  config.vim.session.persisted.enable = true;
}
