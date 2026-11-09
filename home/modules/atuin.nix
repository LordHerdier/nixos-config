# home/modules/atuin.nix

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      enter_accept = true;
      sync.records = true;

      # `atuin config enable threads` can't write to the read-only HM-managed
      # config, so the equivalent (threads plus the daemon they depend on) is here.
      threads.capture = true;
      daemon = {
        enabled = true;
        autostart = true;
      };
    };
  };
}
