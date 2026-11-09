# Turns the `keys` table in pkgs/dwl/config.h into "combo<TAB>what it does"
# lines for dwl-binds. Built once by scripts.nix, so the list can never drift
# from the binds actually compiled in. Needs gawk (match() with an array).

function mods(s,    out, n, parts, i, m) {
	n = split(s, parts, /\|/)
	for (i = 1; i <= n; i++) {
		m = parts[i]
		gsub(/[ \t]/, "", m)
		sub(/^WLR_MODIFIER_/, "", m)
		if (m == "0") continue
		if (m == "MODKEY" || m == "LOGO") m = "Super"
		else m = toupper(substr(m, 1, 1)) tolower(substr(m, 2))
		out = out m "+"
	}
	return out
}

function keyname(k) {
	if (k in names) return names[k]
	if (length(k) == 1) return toupper(k)
	return k
}

function describe(fn, arg,    c) {
	if (fn == "spawn" || fn == "spawnfocused") {
		if (match(arg, /MODAL\("([^"]*)"\)/, c)) return "open the " c[1] " popup"
		if (match(arg, /SHCMD\(VOLCMD\("([^"]*)"\)\)/, c)) return "volume " c[1]
		if (match(arg, /SHCMD\("(.*)"\)/, c)) return c[1]
		if (arg ~ /termcmd/) return "terminal"
		if (arg ~ /floatterm/) return "floating terminal"
		return arg
	}
	if (fn == "focusdir" || fn == "focusmon" || fn == "tagmon") {
		if (match(arg, /WLR_DIRECTION_([A-Z]+)/, c)) return fn " " tolower(c[1])
	}
	if (fn in gapfns && match(arg, /\.i *= *([-+]?[0-9]+)/, c)) return gapfns[fn] " " c[1] "px"
	if (fn == "togglegaps") return "gaps on/off"
	if (fn == "defaultgaps") return "reset gaps"
	if (fn == "rotate_clients") return (arg ~ /-/) ? "rotate windows up" : "rotate windows down"
	sub(/^\{ */, "", arg); sub(/\}? *$/, "", arg)
	sub(/^\.[a-z]+ *= */, "", arg)
	return (arg == "0" || arg == "") ? fn : fn " " arg
}

BEGIN {
	names["period"] = "."; names["comma"] = ","; names["slash"] = "/"
	names["space"] = "Space"; names["Return"] = "Enter"; names["grave"] = "`"
	names["equal"] = "="; names["minus"] = "-"; names["plus"] = "+"
	names["underscore"] = "_"; names["BackSpace"] = "Backspace"
	names["bracketleft"] = "["; names["bracketright"] = "]"
	names["braceleft"] = "{"; names["braceright"] = "}"
	names["backslash"] = "\\"; names["bar"] = "|"
	gapfns["incgaps"] = "all gaps"; gapfns["incogaps"] = "outer gaps"
	gapfns["incigaps"] = "inner gaps"
	gapfns["incihgaps"] = "gap between stacked windows"
	gapfns["incivgaps"] = "gap between columns"
	gapfns["incohgaps"] = "top/bottom edge gap"
	gapfns["incovgaps"] = "left/right edge gap"
	print "Super+1 … 0\tview workspace"
	print "Super+Shift+1 … 0\tmove window to workspace"
	print "Super+Ctrl+1 … 0\ttoggle workspace in view"
	print "Super+Ctrl+Shift+1 … 0\ttoggle window on workspace"
}

# Only the Key table: tab-indented `{ mods, XKB_KEY_x, func, arg },` rows.
/^\t\{ *[A-Za-z0-9_|0 ]+, *XKB_KEY_/ && !/NOCTALIA_STUB/ {
	line = $0
	sub(/[ \t]*\/\*.*\*\/[ \t]*$/, "", line)
	sub(/[ \t]+$/, "", line)
	if (!match(line, /^\t\{ *([^,]+), *XKB_KEY_([A-Za-z0-9_]+), *([a-z]+), *(.*)\},?$/, m)) next
	print mods(m[1]) keyname(m[2]) "\t" describe(m[3], m[4])
}
