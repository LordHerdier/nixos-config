# home/modules/zen-browser/80-spaces.nix
#
# Zen [work]spaces, their themes, and the routing rules that decide which
# space a URL opens in.
#
# IDS ARE IDENTITY. A space is keyed by its uuid, not its name: changing
# `id` re-creates the space as a new one and loses its open tabs (and
# with spacesForce, deletes the old one). Generate them once with
# `uuidgen` and keep them.
#
# Spaces are stored in zen-sessions.jsonlz4 and routing in
# zen-space-routing.jsonlz4 -- close Zen before a switch.
#
# Pins and live folders can be declared under a space instead of at
# profile level, in which case `workspace` is derived from the space id.
# This file keeps the space definitions; 85-pins.nix keeps the tabs.
{ ... }:

{
  programs.zen-browser.profiles.default = {
    # spacesForce = true; # delete spaces not declared here
    # spaces = {
    #   "Personal" = {
    #     id = "00000000-0000-0000-0000-000000000000"; # uuidgen
    #     position = 1000;
    #     icon = "🏠";
    #   };
    #   "Work" = {
    #     id = "00000000-0000-0000-0000-000000000001";
    #     position = 2000;
    #     icon = "💼";
    #     container = 2; # a container id from 70-containers.nix
    #     theme = {
    #       type = "gradient";
    #       colors = [
    #         {
    #           red = 100;
    #           green = 150;
    #           blue = 200;
    #           algorithm = "floating";
    #           type = "explicit-lightness";
    #           lightness = 50;
    #         }
    #       ];
    #       opacity = 0.8;
    #       texture = 0.5;
    #     };
    #   };
    # };

    # Routing. `openIn` / `defaultExternalRoute` take a space id (without
    # braces) or the literal "most-recent-space". Undeclared routes Zen
    # made are kept unless `force = true`.
    # spaceRouting = {
    #   defaultExternalRoute = "00000000-0000-0000-0000-000000000001";
    #   routes = {
    #     "github" = {
    #       reference = "github.com";
    #       matchType = "contains"; # contains | equal-to | regex
    #       openIn = "00000000-0000-0000-0000-000000000001";
    #     };
    #   };
    # };
  };
}
