# modules/features/fingerprint-reader.nix

{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.fprintd ];

  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix;
  };

  services.udev.packages = [ pkgs.libfprint-2-tod1-goodix ];

  services.udev.extraRules = ''
    # Disable USB autosuspend for Goodix fingerprint reader (27c6:609c)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="609c", ATTR{power/autosuspend}="-1", ATTR{power/persist}="0"
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

  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.polkit-1.fprintAuth = true;

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
