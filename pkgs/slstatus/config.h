/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 5000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 4096

/* dwl's bar (05-bar.patch) reads one line of this from its stdin. @volume@ and
 * @battery@ are substituted by default.nix with scripts that print the
 * PipeWire sink volume and BAT1's charge, coloured with ^fg(), and
 * @notifications@ with a bell that shows mako's Do Not Disturb, after a cup
 * while dwl-caffeine is on, @keyboard@ with the active keyboard layout, and
 * @brightness@ with the backlight level (accent while dwl-nightlight is on),
 * and @network@ with the Wi-Fi name and a bt marker for connected Bluetooth
 * devices.
 * dwl's volume and brightness keys and layout switch, dwl-dnd, dwl-caffeine
 * and dwl-nightlight send SIGUSR1 to redraw immediately.
 *
 * @accent@ and @muted@ are my.theme colours as rrggbb, also from default.nix.
 *
 * ^fg(...) colours, ^lm/^rm/^us/^ds(...) click/scroll regions and ^ct()
 * centring are dwl's inline status commands (95-bar-status-commands.patch,
 * 96-bar-status-centre.patch). A region command ends at the first ')', so
 * none of these may contain one. */
#define LABEL(text) "^fg(@accent@)" text "^fg()"
#define SEP         "^fg(@muted@) | ^fg()"
#define VOL         "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "
#define BRI         "brightnessctl -q -c backlight set "
#define REDRAW      "; pkill -USR1 slstatus"

static const struct arg args[] = {
	/* function       format           argument */
	/* notifications bell: left click centre, middle click clear all,
	 * right click toggles do not disturb */
	{ run_command,
	  "^lm(dwl-modal notifications 120 30 dwl-notifications)"
	  "^mm(dwl-notifications --clear)^rm(dwl-dnd)"
	  "%s^lm()^mm()^rm()" SEP,
	  "@notifications@" },
	/* keyboard layout, switched with Super+Alt+K */
	{ run_command,    LABEL("kb ") "%s" SEP, "@keyboard@" },
	/* network: left click dwl-network (Super+Alt+A), right click toggles
	 * Wi-Fi, middle click Bluetooth */
	{ run_command,
	  "^lm(dwl-modal network 90 24 dwl-network)"
	  "^rm(dwl-network --toggle-wifi)^mm(dwl-network --toggle-bluetooth)"
	  LABEL("net ") "%s^lm()^rm()^mm()" SEP,
	  "@network@" },
	/* brightness: left click night light (Super+Shift+N), right click
	 * caffeine (Super+Shift+I), scroll +-5% */
	{ run_command,
	  "^lm(dwl-nightlight)^rm(dwl-caffeine)"
	  "^us(" BRI "5%%+" REDRAW ")^ds(" BRI "5%%-" REDRAW ")"
	  LABEL("bri ") "%s^lm()^rm()^us()^ds()" SEP,
	  "@brightness@" },
	/* volume: left click mixer, right click mute, scroll +-5% */
	{ run_command,
	  "^lm(dwl-modal mixer 110 30 wiremix)"
	  "^rm(wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" REDRAW ")"
	  "^us(" VOL "5%%+" REDRAW ")^ds(" VOL "5%%-" REDRAW ")"
	  LABEL("vol ") "%s^lm()^rm()^us()^ds()" SEP,
	  "@volume@" },
	{ run_command,    LABEL("bat ") "%s", "@battery@" },
	/* clock, centred on the bar by ^ct(): left click toggles dwl-calendar
	 * (Super+K) */
	{ datetime,
	  "^ct()^lm(dwl-modal calendar 66 11 dwl-calendar)%s^lm()^ct()",
	  "%a %d %b %H:%M" },
};
