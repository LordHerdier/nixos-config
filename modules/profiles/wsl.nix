# modules/profiles/wsl.nix

{ ... }:

{
  wsl = {
    enable = true;
    defaultUser = "charlotte";
    startMenuLaunchers = true;

    wslConf = {
      interop.appendWindowsPath = false;
      network.generateResolvConf = false;
    };
  };

  # WSL has no display manager/seat to start the user systemd instance, so
  # without lingering there's no user manager/dbus session for nixos-rebuild
  # to reload user units against on switch.
  users.users.charlotte.linger = true;

  # WSL2's cgroup v2 hierarchy doesn't support the delegated "init.scope"
  # subgroup systemd 256+ wants for user@.service by default: starting it
  # fails with "Failed to spawn 'start' task: Device or resource busy".
  # Disable delegation, which isn't needed here anyway.
  systemd.services."user@".serviceConfig = {
    Delegate = false;
    DelegateSubgroup = "";
  };
}
