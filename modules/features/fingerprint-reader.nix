# modules/features/fingerprint-reader.nix

{ lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.fprintd ];

  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix;
  };

  # Deliberately NOT in services.udev.packages: its rules only match Goodix
  # 538c/533c/530c/5840, not this 27c6:609c, so all they'd add is
  # "Failed to resolve group 'plugdev'" warnings. tod.driver provides the .so.

  services.udev.extraRules = ''
    # Keep the Goodix reader (27c6:609c) from autosuspending. hwdb sets
    # ID_AUTOSUSPEND=1 (power/control "auto"), so a negative delay is what
    # stops it. power/persist comes from hwdb's ID_PERSIST=0 already.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="609c", ATTR{power/autosuspend}="-1"
  '';

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "net.reactivated.fprint.device.enroll" ||
           action.id == "net.reactivated.fprint.device.setusername" ||
           action.id == "net.reactivated.fprint.device.verify") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  security.pam.services = lib.genAttrs [ "sudo" "login" "polkit-1" ] (_: {
    fprintAuth = true;
    rules.auth.fprintd.args = [
      "max-tries=1"
      "timeout=3"
    ];
  });

  environment.etc."polkit-1/actions/com.bitwarden.Bitwarden.policy" = {
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE policyconfig PUBLIC
       "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
       "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">

      <policyconfig>
          <action id="com.bitwarden.Bitwarden.unlock">
            <description>Unlock Bitwarden</description>
            <message>Authenticate to unlock Bitwarden</message>
            <defaults>
              <allow_any>no</allow_any>
              <allow_inactive>no</allow_inactive>
              <allow_active>auth_self</allow_active>
            </defaults>
          </action>
      </policyconfig>
    '';
    mode = "0644";
  };
}
