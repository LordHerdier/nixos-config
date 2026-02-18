# home/modules/zsh/default.nix

{ ... }:

{
  imports = [
    ./aliases.nix
    ./profile.nix
    ./wsl.nix      #gated behind isWsl:true

    ./init/00-guard.nix
    ./init/10-paths-xdg-editor.nix
    ./init/20-zoxide.nix
    ./init/30-oh-my-posh.nix
    ./init/40-ssh-agent.nix
    ./init/50-history-completion.nix
    ./init/60-functions.nix
    ./init/99-private-extras.nix
  ];

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}

