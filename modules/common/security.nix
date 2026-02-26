# modules/security.nix

{ ... }:

{
  security = {
    sudo = {
      wheelNeedsPassword = true;

      extraConfig = ''
        Defaults env_keep += "SSH_AUTH_SOCK"
      '';
    };
  };
}
