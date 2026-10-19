# home/modules/zen-browser/85-pins.nix
#
# Pinned tabs, essentials, folders, split views and live folders -- the
# tab-side contents of the spaces defined in 80-spaces.nix. All of it
# lands in zen-sessions.jsonlz4 (live folders additionally in
# zen-live-folders.jsonlz4), so close Zen before a switch.
#
# Every pin needs a stable uuid of its own, same rule as spaces.
#
# TWO DECLARATION FORMS, freely mixable:
#   - flat `pins`, pointing at a space with `workspace = <space id>`
#   - `spaces.<name>.pins`, which derives `workspace` from the space
#
# FOLDERS, likewise:
#   - embedded: nest children under the folder pin's own `pins`;
#     `isGroup` is implied and children inherit workspace/parent
#   - flat: `isGroup = true` on the folder, siblings point at it with
#     `folderParentId`
#
# `pinsForce = true` reconciles undeclared pins; `pinsForceAction`
# chooses "demote" (default, becomes a normal tab) or "remove".
{ ... }:

{
  programs.zen-browser.profiles.default = {
    # pinsForce = true;
    # pinsForceAction = "demote"; # or "remove"

    # pins = {
    #   "Email" = {
    #     id = "00000000-0000-0000-0000-000000000010";
    #     url = "https://mail.proton.me";
    #     position = 101;
    #     isEssential = true;
    #     workspace = "00000000-0000-0000-0000-000000000000";
    #   };
    #
    #   "Dev Tools" = {
    #     id = "00000000-0000-0000-0000-000000000011";
    #     position = 200;
    #     isFolderCollapsed = false;
    #     folderIcon = "chrome://browser/skin/zen-icons/selectable/eye.svg";
    #
    #     pins."NixOS Packages" = {
    #       id = "00000000-0000-0000-0000-000000000012";
    #       url = "https://search.nixos.org/packages";
    #       position = 201;
    #     };
    #   };
    # };

    # Split views over already-declared pins, by tab id.
    # joinedTabs."Docs and issues" = {
    #   id = "docs-issues-split";
    #   gridType = "vsep";
    #   tabs = [
    #     "00000000-0000-0000-0000-000000000010"
    #     "00000000-0000-0000-0000-000000000012"
    #   ];
    #   # sizes = [ 70 30 ]; # percent of parent, must sum to 100
    # };

    # Folders the browser fills itself from a feed or a GitHub query.
    # `workspace` is required at profile level; the GitHub kinds reuse the
    # browser's github.com session, so no token. Nesting one inside a
    # regular folder pin needs that parent to be `isGroup = true`.
    # liveFolders = {
    #   "Pull requests" = {
    #     id = "00000000-0000-0000-0000-000000000020";
    #     kind = "github:pull-requests"; # rss | github:issues | ...
    #     workspace = "00000000-0000-0000-0000-000000000001";
    #     position = 401;
    #     github = {
    #       assignedMe = true; # default
    #       reviewRequested = true;
    #     };
    #   };
    # };
  };
}
