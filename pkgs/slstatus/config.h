/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 5000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/* dwl's bar (05-bar.patch) reads one line of this from its stdin. @volume@ and
 * @battery@ are substituted by default.nix with scripts that print the
 * PipeWire sink volume and BAT1's charge, coloured with ^fg(), and
 * @notifications@ with a bell that shows mako's Do Not Disturb. dwl's volume
 * keys and dwl-dnd send SIGUSR1 to redraw immediately.
 *
 * @accent@ and @muted@ are my.theme colours as rrggbb, also from default.nix.
 *
 * ^fg(...) colours and ^lm/^rm/^us/^ds(...) click/scroll regions are dwl's
 * inline status commands (95-bar-status-commands.patch). A region command
 * ends at the first ')', so none of these may contain one. */
#define LABEL(text) "^fg(@accent@)" text "^fg()"
#define SEP         "^fg(@muted@) | ^fg()"
#define VOL         "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "
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
	/* volume: left click mixer, right click mute, scroll +-5% */
	{ run_command,
	  "^lm(dwl-modal mixer 110 30 wiremix)"
	  "^rm(wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" REDRAW ")"
	  "^us(" VOL "5%%+" REDRAW ")^ds(" VOL "5%%-" REDRAW ")"
	  LABEL("vol ") "%s^lm()^rm()^us()^ds()" SEP,
	  "@volume@" },
	{ run_command,    LABEL("bat ") "%s" SEP, "@battery@" },
	/* clock: left click toggles a three-month calendar */
	{ datetime,
	  "^lm(dwl-modal calendar 66 10 --hold cal -3)%s^lm()",
	  "%a %d %b %H:%M" },
};
