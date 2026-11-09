# home/modules/zen-browser/50-search.nix
#
# Search engines, same shape as programs.firefox.profiles.*.search.
# `force = true` is required for the declared set to replace whatever the
# browser has stored, on every rebuild.
{ pkgs, ... }:

{
  programs.zen-browser.profiles.default.search = {
    # force = true;
    # default = "ddg";

    # engines = {
    #   mynixos = {
    #     name = "My NixOS";
    #     urls = [ { template = "https://mynixos.com/search?q={searchTerms}"; } ];
    #     icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    #     definedAliases = [ "@nx" ];
    #   };
    # };
  };
}
