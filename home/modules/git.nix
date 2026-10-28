# home/modules/git.nix

{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      core.hooksPath = ".githooks";
    };
  };
}
