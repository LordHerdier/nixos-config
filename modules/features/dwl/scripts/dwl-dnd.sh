# dwl-dnd
#
# Toggles Do Not Disturb (Super+Alt+W, or right-clicking the bar's bell),
# standing in for Noctalia's notification-dnd-toggle. mako's do-not-disturb
# mode (mako.conf) hides new notifications; they still reach the history
# dwl-notifications shows. The bar's bell is crossed out while it's on.

makoctl mode -t do-not-disturb >/dev/null
dwl-bar-refresh
