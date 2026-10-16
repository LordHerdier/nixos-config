# home/modules/nvf/plugins/75-project.nix
#
# Project awareness and session persistence.

{ ... }:

{
  # Also revives the `fp` telescope mapping in ../20-telescope.nix: nvf only
  # creates that keymap (and loads the `projects` extension) when this module
  # is enabled, so until now `fp` was bound to nothing.
  config.vim.projects.project-nvim = {
    enable = true;

    setupOpts = {
      # nvf's default. Projects are detected and recorded, but the cwd is only
      # changed on request -- via the `fp` picker or :ProjectRoot -- rather
      # than silently moving out from under you on every buffer switch.
      manual_mode = true;
      detection_methods = [
        "lsp"
        "pattern"
      ];
    };
  };

  # <leader>qs loads the session for the cwd, <leader>ql picks from the list.
  # Does not collide with `Q` (quit) from ../90-keymaps.nix.
  config.vim.session.persisted.enable = true;
}
