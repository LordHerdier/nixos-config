# modules/profiles/server.nix — headless homelab server baseline
#
# For `mkHost { withHome = false; }` guests on twm. Ansible
# (~/documents/code/inframanagement) owns the VM/CT from the outside (clone,
# resources, Caddy routes); everything inside is declared here and in the
# host file. These hosts sit in Ansible's `nixos` inventory group, which
# every mutating playbook skips.
#
# Admin access is root over SSH by key (Ansible's `ansible_user: root`, and
# `nh os switch --target-host root@<ip>`). charlotte has no password here,
# so she deliberately can't sudo.
#
# Pair with modules/profiles/proxmox-vm.nix or proxmox-lxc.nix.

{ pkgs, ... }:

let
  # Charlotte's interactive key (same key on Pine and Index).
  adminKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMkOTHjuB7f+raL44rpjdwHWlbiODQGdqj3fpVmX9VUu charlotte@pine";

  # Semaphore's key (~/.ssh/id_semaphore.pub on Index; Ansible's
  # semaphore_key.yml installs it everywhere else). Lets the read-only
  # playbooks (ping_sweep, disk_usage) reach these hosts from Semaphore.
  semaphoreKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZwxif1pIZohP7oa1ksFSaK6sxxrussGGbzUmHjIxKg charlotte@Index";
in
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitEmptyPasswords = false;
      PermitRootLogin = "prohibit-password";
      # A list option, so a host can append its own service users
      # (Builder adds nixbuild).
      AllowUsers = [
        "root"
        "charlotte"
      ];
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    adminKey
    semaphoreKey
  ];
  users.users.charlotte.openssh.authorizedKeys.keys = [ adminKey ];

  # Ansible modules (even ping, and the shell module disk_usage uses) need a
  # Python on the target. interpreter_python = auto_silent finds this one.
  environment.systemPackages = [ pkgs.python3 ];

  # Long-lived guests with small disks: cap the journal rather than let it
  # grow to journald's 10%-of-filesystem default.
  services.journald.settings.Journal.SystemMaxUse = "1G";

  documentation.nixos.enable = false;
}
