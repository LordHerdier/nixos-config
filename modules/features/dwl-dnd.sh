# dwl-dnd
#
# Toggles Do Not Disturb (Super+Alt+W, or right-clicking the bar's bell),
# standing in for Noctalia's notification-dnd-toggle. mako's do-not-disturb
# mode (see makoConfig in modules/features/dwl.nix) hides new notifications;
# they still time out into the history that dwl-notifications shows. The bell
# turns into a crossed-out one while it's on, so slstatus is asked to redraw.

makoctl mode -t do-not-disturb >/dev/null
pkill -USR1 -x slstatus || true
