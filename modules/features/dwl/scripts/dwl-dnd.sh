# dwl-dnd
#
# Toggles Do Not Disturb (Super+Alt+W, or right-clicking the bar's bell),
# standing in for Noctalia's notification-dnd-toggle. mako's do-not-disturb
# mode (see modules/features/dwl/mako.conf) hides new notifications; they
# still time out into the history that dwl-notifications shows. The bell
# turns into a crossed-out one while it's on, so the bar is redrawn.

makoctl mode -t do-not-disturb >/dev/null
dwl-bar-refresh
