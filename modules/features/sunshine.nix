# modules/features/sunshine.nix
# Sunshine self-hosted game stream host, for Moonlight clients to connect to.
#
# Runs as a per-user systemd unit tied to graphical-session.target, so it
# only comes up once a Wayland/X session (e.g. GNOME via SDDM) is
# actually logged in and running.

{ ... }:

{
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = true;

    # GNOME (mutter) captures via the xdg-desktop-portal ScreenCast
    # interface + PipeWire rather than raw DRM/KMS, so no CAP_SYS_ADMIN
    # is needed here (that was only for Hyprland's wlroots capture path).
    #
    # NOTE: the portal's first ScreenCast request needs someone logged
    # in locally to click "Share" once — there's no headless bypass. On
    # an autologin/streaming box like this, log in once after a rebuild
    # (e.g. via the Proxmox console) and approve the prompt before
    # expecting Moonlight to show a picture; GNOME remembers the grant
    # after that.
    capSysAdmin = false;

    settings = {
      sunshine_name = "Apthos";
    };
  };
}
