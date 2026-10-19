# home/modules/zen-browser/60-bookmarks.nix
#
# Bookmarks. `force = true` rewrites them on every rebuild, discarding
# anything added from the browser.
#
# `toolbar = true` marks a directory AS the bookmarks toolbar and its
# name is dropped -- it does not place that directory inside the toolbar.
# To get a folder onto the toolbar, nest it inside the toolbar directory.
# Directories without `toolbar` land in the bookmarks menu.
{ ... }:

{
  programs.zen-browser.profiles.default.bookmarks = {
    # force = true;
    # settings = [
    #   {
    #     name = "Bookmarks Toolbar";
    #     toolbar = true;
    #     bookmarks = [
    #       {
    #         name = "Nix";
    #         bookmarks = [
    #           { name = "packages"; url = "https://search.nixos.org/packages"; }
    #           { name = "wiki"; tags = [ "nix" "wiki" ]; url = "https://wiki.nixos.org/"; }
    #         ];
    #       }
    #     ];
    #   }
    # ];
  };
}
