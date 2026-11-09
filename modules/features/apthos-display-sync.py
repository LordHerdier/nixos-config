# Sync the Sony TV's refresh rate / HDR / VRR to a connecting Sunshine
# (Moonlight) client, then restore the native mode when the stream ends.
#
# Sunshine passes SUNSHINE_CLIENT_WIDTH/HEIGHT/FPS/HDR; no VRR signal.
# Resolution isn't matched: the TV's EDID modes (4096x2160, 3840x2160,
# 1920x1080, ...) never contain a laptop's (e.g. 2880x1920), and the
# encoder scales anyway. What matters:
#   - refresh rate: match it so frame pacing doesn't judder
#   - HDR: raw PQ looks washed out on a non-HDR client, so SDR unless
#     SUNSHINE_CLIENT_HDR=1
#   - VRR: always off while streaming; it confuses screencast frame pacing
import json
import os
import sys

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

# The TV has moved between the GPU's HDMI and DP outputs; use whichever of
# these is attached.
CONNECTORS = ["HDMI-1", "DP-1"]
STATE_FILE = os.path.expanduser("~/.local/state/sunshine-display-sync.json")
METHOD_TEMPORARY = 1
COLOR_MODE_SDR = 0
COLOR_MODE_HDR = 1


def proxy():
    return Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION,
        Gio.DBusProxyFlags.NONE,
        None,
        "org.gnome.Mutter.DisplayConfig",
        "/org/gnome/Mutter/DisplayConfig",
        "org.gnome.Mutter.DisplayConfig",
        None,
    )


def get_state(p):
    return p.call_sync(
        "GetCurrentState", None, Gio.DBusCallFlags.NONE, -1, None
    ).unpack()


def find_monitor(monitors, connectors):
    attached = {ids[0]: (modes, mprops) for ids, modes, mprops in monitors}
    for connector in connectors:
        if connector in attached:
            return (connector, *attached[connector])
    raise SystemExit(f"none of {', '.join(connectors)} present")


def current_mode(modes):
    for m in modes:
        if m[6].get("is-current"):
            return m
    raise SystemExit("no mode marked is-current")


def current_scale(logical_monitors, connector):
    for x, y, scale, transform, primary, mons, lprops in logical_monitors:
        if any(c == connector for c, *_ in mons):
            return scale
    raise SystemExit(f"no logical monitor for {connector}")


def is_vrr(mode):
    return mode[6].get("refresh-rate-mode") == "variable"


def apply(p, serial, connector, mode_id, scale, color_mode):
    logical = [
        (0, 0, scale, 0, True, [(connector, mode_id, {"color-mode": GLib.Variant("u", color_mode)})])
    ]
    p.call_sync(
        "ApplyMonitorsConfig",
        GLib.Variant("(uua(iiduba(ssa{sv}))a{sv})", (serial, METHOD_TEMPORARY, logical, {})),
        Gio.DBusCallFlags.NONE,
        -1,
        None,
    )


def start():
    p = proxy()
    serial, monitors, logical_monitors, _ = get_state(p)
    connector, modes, mprops = find_monitor(monitors, CONNECTORS)
    native = current_mode(modes)
    scale = current_scale(logical_monitors, connector)

    if not os.path.exists(STATE_FILE):
        os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
        with open(STATE_FILE, "w") as f:
            json.dump(
                {
                    "connector": connector,
                    "mode_id": native[0],
                    "scale": scale,
                    "color_mode": mprops.get("color-mode", COLOR_MODE_SDR),
                },
                f,
            )

    try:
        width, height = native[1], native[2]
        fps = float(os.environ["SUNSHINE_CLIENT_FPS"])
    except (KeyError, ValueError):
        print("apthos-display-sync: no SUNSHINE_CLIENT_FPS, leaving display alone", file=sys.stderr)
        return

    hdr = os.environ.get("SUNSHINE_CLIENT_HDR") == "1"

    candidates = [m for m in modes if m[1] == width and m[2] == height and not is_vrr(m)]
    if not candidates:
        print(f"apthos-display-sync: no fixed-rate mode at {width}x{height}", file=sys.stderr)
        return
    target = min(candidates, key=lambda m: abs(m[3] - fps))

    apply(p, serial, connector, target[0], scale, COLOR_MODE_HDR if hdr else COLOR_MODE_SDR)
    print(f"apthos-display-sync: switched to {target[0]} hdr={hdr}", file=sys.stderr)


def stop():
    if not os.path.exists(STATE_FILE):
        return
    with open(STATE_FILE) as f:
        native = json.load(f)
    os.remove(STATE_FILE)

    p = proxy()
    serial, monitors, _, _ = get_state(p)
    # Restore the same output start() changed; fall back for state files
    # written before the connector was recorded.
    connector = native.get("connector") or find_monitor(monitors, CONNECTORS)[0]
    apply(p, serial, connector, native["mode_id"], native["scale"], native["color_mode"])
    print(f"apthos-display-sync: restored {native['mode_id']}", file=sys.stderr)


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("start", "stop"):
        raise SystemExit(f"usage: {sys.argv[0]} start|stop")
    try:
        {"start": start, "stop": stop}[sys.argv[1]]()
    except GLib.Error as e:
        # Never block a stream over a display-config hiccup.
        print(f"apthos-display-sync: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
