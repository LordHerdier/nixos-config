# hosts/Pine/ambxst.nix

{ lib, ... }:

{
  programs.ambxst = {
    enable = true;

    # If you already manage fonts elsewhere, you can flip this off.
    fonts.enable = true;
  };

  # These are mkDefault in Ambxst, so this just makes it explicit you’re okay with it.
  services.upower.enable = lib.mkDefault true;
  services.power-profiles-daemon.enable = lib.mkDefault true;
}
