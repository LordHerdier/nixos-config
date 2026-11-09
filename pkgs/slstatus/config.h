/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 5000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 4096

/* dwl's bar (06-bar.patch) reads one line of this from its stdin. default.nix
 * replaces @volume@ and the like with the ./scripts that print those blocks.
 * Whatever changes a block (dwl's volume, brightness and layout keys,
 * dwl-dnd, dwl-caffeine, dwl-nightlight...) runs dwl-bar-refresh to redraw
 * at once, as REDRAW below does.
 *
 * The inline commands are dwl's: ^fg(...) colours, where accent/muted/alert/
 * good are theme names that follow dwl-theme (75-theme-colours.patch);
 * ^lm/^mm/^rm/^us/^ds(cmd) click and scroll regions
 * (57-bar-status-commands.patch); ^ct() centring (60-bar-status-centre.patch);
 * ^hv(text) hover text (81-bar-status-hover.patch). An argument ends at the
 * first ')', so none may contain one. */
#define LABEL(text) "^fg(accent)" text "^fg()"
#define SEP         "^fg(muted) | ^fg()"
#define VOL         "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "
#define BRI         "brightnessctl -q -c backlight set "
#define REDRAW      "; dwl-bar-refresh"

static const struct arg args[] = {
	/* function       format           argument */
	/* notifications bell: left click centre, middle click clear all,
	 * right click toggles do not disturb */
	{ run_command,
	  "^lm(dwl-modal notifications)"
	  "^mm(dwl-notifications --clear)^rm(dwl-dnd)"
	  "%s^lm()^mm()^rm()" SEP,
	  "@notifications@" },
	/* keyboard layout: left click switches it, as Super+Alt+K does */
	{ run_command,
	  "^lm(dwl-xkb-switch)"
	  LABEL("kb ") "%s^lm()" SEP,
	  "@keyboard@" },
	/* network: left click dwl-settings network (Super+Alt+A); the script adds the
	 * right-click regions that toggle Wi-Fi and Bluetooth */
	{ run_command,
	  "^lm(dwl-modal network)"
	  LABEL("net ") "%s^lm()" SEP,
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
	  "^lm(dwl-modal mixer)"
	  "^rm(wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" REDRAW ")"
	  "^us(" VOL "5%%+" REDRAW ")^ds(" VOL "5%%-" REDRAW ")"
	  LABEL("vol ") "%s^lm()^rm()^us()^ds()" SEP,
	  "@volume@" },
	{ run_command,    LABEL("bat ") "%s", "@battery@" },
	/* clock, centred on the bar by ^ct(): left click toggles dwl-calendar
	 * (Super+K) */
	{ datetime,
	  "^ct()^lm(dwl-modal calendar)%s^lm()^ct()",
	  "%a %d %b %H:%M" },
};
