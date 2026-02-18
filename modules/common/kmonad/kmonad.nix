# modules/common/kmonad/default.nix

{  pkgs, ... }:

{
  environment.systemPackages = [ pkgs.kmonad ];

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

