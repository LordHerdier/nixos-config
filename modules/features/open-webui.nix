# modules/features/open-webui.nix
# Open WebUI, run as a Docker container (per upstream's quick-start:
# https://docs.openwebui.com/getting-started/quick-start) talking to the
# Ollama server on this same host (see ollama-vulkan.nix).
#
# The container publishes only on 127.0.0.1 and `tailscale serve` fronts it
# with HTTPS at https://apthos.tailc769e7.ts.net/ (tailnet-only, no
# funnel). Binding to loopback also means Docker's own DNAT rules, which
# bypass the NixOS firewall, have nothing to expose.

{ pkgs, ... }:

let
  dataDir = "/opt/open-webui";
in
{
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
    "d ${dataDir}/data 0750 root root -"
  ];

  # WEBUI_SECRET_KEY signs session cookies: generated once, outside the
  # world-readable store, so it persists across rebuilds.
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

  # tailscaled persists serve config itself; this declares it and reapplies
  # it if tailscaled's state is ever reset.
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
