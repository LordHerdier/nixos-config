# modules/features/sunshine.nix
# Sunshine self-hosted game stream host, for Moonlight clients to connect to.
#
# Runs as a per-user systemd unit tied to graphical-session.target, so it
# only comes up once a Wayland/X session (e.g. Hyprland via SDDM) is
# actually logged in and running.

{ ... }:

{
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = true;

    # DRM/KMS capture needs CAP_SYS_ADMIN on the binary; required here since
    # the compositor is Hyprland (wlroots), not X11 with NvFBC.
    capSysAdmin = true;

    settings = {
      sunshine_name = "Apthos";
    };
  };
}
