# modules/profiles/laptop.nix

{ ... }:

{
  hardware = {
    bluetooth = {
      enable = true;
    };
  };

  services = {
    libinput = {
      enable = true;
    };
  };
}
