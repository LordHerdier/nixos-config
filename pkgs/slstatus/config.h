/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 5000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/* dwl's bar (05-bar.patch) reads one line of this from its stdin. @volume@ is
 * substituted by default.nix with a script that prints the PipeWire sink
 * volume; dwl's volume keys send SIGUSR1 to redraw immediately. */
static const struct arg args[] = {
	/* function       format           argument */
	{ run_command,    "vol %s | ",     "@volume@" },
	{ battery_perc,   "bat %s%%",      "BAT1" },
	{ battery_state,  " %s | ",        "BAT1" }, /* + charging, - discharging, o idle */
	{ datetime,       "%s",            "%a %d %b %H:%M" },
};
