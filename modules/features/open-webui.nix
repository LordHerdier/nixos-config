# modules/features/open-webui.nix
# Open WebUI, run as a Docker container (per upstream's quick-start:
# https://docs.openwebui.com/getting-started/quick-start) talking to the
# Ollama server on this same host (see ollama-vulkan.nix).
#
# The container only publishes to 127.0.0.1 -- not reachable on any network
# interface at all -- and `tailscale serve` fronts it with a proper HTTPS
# cert at https://apthos.tailc769e7.ts.net/, tailnet-only (no funnel). This
# also sidesteps Docker's `-p` publishing installing its own iptables
# DNAT/FORWARD rules ahead of the NixOS firewall's INPUT chain: binding to
# loopback means there's no published port for those rules to ever expose.

{ pkgs, ... }:

let
  dataDir = "/opt/open-webui";
in
{
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
    "d ${dataDir}/data 0750 root root -"
  ];

  # WEBUI_SECRET_KEY signs session cookies; generate it once and keep it out
  # of the Nix store (world-readable) so rebuilds don't invalidate sessions
  # or leak it.
  systemd.services.open-webui-secret = {
    description = "Generate a persistent Open WebUI session secret";
    before = [ "docker-open-webui.service" ];
    requiredBy = [ "docker-open-webui.service" ];
    unitConfig.ConditionPathExists = "!${dataDir}/webui-secret.env";
    serviceConfig.Type = "oneshot";
    script = ''
      umask 077
      echo "WEBUI_SECRET_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 32)" > ${dataDir}/webui-secret.env
    '';
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.open-webui = {
    image = "ghcr.io/open-webui/open-webui:slim";
    ports = [ "127.0.0.1:3000:8080" ];
    volumes = [ "${dataDir}/data:/app/backend/data" ];
    environment = {
      OLLAMA_BASE_URL = "http://host.docker.internal:11434";
    };
    environmentFiles = [ "${dataDir}/webui-secret.env" ];
    extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
  };

  # Registers the mapping with tailscaled, which persists it in its own
  # state and keeps serving it across reboots -- this unit just makes that
  # declared in config instead of a one-off imperative command, and reapplies
  # it if tailscaled's state ever gets reset.
  systemd.services.tailscale-serve-open-webui = {
    description = "Expose Open WebUI over Tailscale Serve";
    after = [
      "tailscaled.service"
      "docker-open-webui.service"
    ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --yes 3000";
      ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
    };
  };
}
