# modules/common/kmonad/kmonad.nix

{ pkgs, lib, ... }:

let
  # One keymap, parameterised by the key that reaches the switcher layer.
  # The builtin board uses right ctrl; the Keychron K6 in Mac mode has no
  # right ctrl, so it uses right alt.
  mkConfig =
    layerKey:
    builtins.replaceStrings [ "@@layer-key@@" ] [ layerKey ] (
      builtins.readFile ./colemakHomerowMods.kbd
    );

  boards = {
    myKMonadOutput = {
      device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
      layerKey = "rctl";
    };
    keychronK6 = {
      device = "/dev/input/keychron-k6";
      layerKey = "ralt";
    };
  };

  # The units charlotte may start/stop/restart without authenticating.
  managedUnits = lib.concatMapStringsSep ", " (u: "\"${u}\"") (
    lib.concatMap (name: [
      "kmonad-${name}.service"
      "kmonad-${name}.path"
    ]) (builtins.attrNames boards)
  );
in
{
  environment.systemPackages = [ pkgs.kmonad ];

  # The K6 over bluetooth is a virtual uhid device with no ID_SERIAL, so udev
  # gives it neither a by-id nor a by-path symlink and its event node number
  # moves between reconnects. Match on the bluetooth MAC: over BT the K6
  # reports itself as Apple 05ac:024f, so vendor/product is not unique.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{uniq}=="dc:2c:26:f2:a0:d0", ATTRS{name}=="Keychron K6", SYMLINK+="input/keychron-k6"
  '';

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var units = [ ${managedUnits} ];
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          units.indexOf(action.lookup("unit")) >= 0 &&
          subject.user == "charlotte") {
        return polkit.Result.YES;
      }
    });
  '';

  services.kmonad = {
    enable = true;
    keyboards = lib.mapAttrs (_: board: {
      inherit (board) device;
      config = mkConfig board.layerKey;
      defcfg = {
        enable = true;
        fallthrough = true;
        # No compose key: the default is ralt, which is the K6's layer key.
        compose.key = null;
      };
    }) boards;
  };
}
