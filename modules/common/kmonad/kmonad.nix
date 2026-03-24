# modules/common/kmonad/default.nix

{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.kmonad ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          (action.lookup("unit") == "kmonad-myKMonadOutput.service" ||
           action.lookup("unit") == "kmonad-myKMonadOutput.path") &&
          subject.user == "charlotte") {
        return polkit.Result.YES;
      }
    });
  '';

  services.kmonad = {
    enable = true;
    keyboards = {
      myKMonadOutput = {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = builtins.readFile ./colemakHomerowMods.kbd;
      };
    };
  };
}
