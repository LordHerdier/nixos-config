# home/modules/nvim.nix

{ config, dotfiles, pkgs, ... }:

{
  home.packages = with pkgs; [
    # --- LSP servers ---
    nil                    # Nix LSP 
    pyright                # Python LSP
    nodePackages.bash-language-server
    nodePackages.yaml-language-server
    nodePackages.svelte-language-server
    vtsls     # TS/JS LSP (vtsls)

    # json lsp: prefer vscode-langservers-extracted (includes jsonls)
    nodePackages.vscode-langservers-extracted

    # --- Formatters / linters / helpers ---
    nodePackages.prettier
    nodePackages.markdownlint-cli2

  ];
  home.file = {
    ".config/nvim" = {
      source = "${dotfiles}/nvim/.config/nvim";
      recursive = true;
    };

    ".config/nvim/lazy-lock.json" = {
      force = true;
      # Make it a symlink to the writable lockfile location
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.stateHome}/nvim/lazy/lazy-lock.json";
    };

  };
}
