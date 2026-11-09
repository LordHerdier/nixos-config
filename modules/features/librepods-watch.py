# Start librepods.service while an Apple Bluetooth device is connected, and
# stop it again once the last one has been gone for GRACE_SECONDS.
#
# Bluetooth connections raise no udev event, so this follows BlueZ over the
# system bus instead: org.bluez.Device1 PropertiesChanged on Connected.
#
# "Apple" is decided from the device's Modalias (the Device ID record), not a
# MAC prefix: Apple owns dozens of OUIs, while the vendor ID is a single value
# (0x004C in the Bluetooth SIG namespace, 0x05AC if the record is USB-sourced).
import subprocess
import sys

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

UNIT = "librepods.service"
GRACE_SECONDS = 180
APPLE_MODALIAS_PREFIXES = ("bluetooth:v004c", "usb:v05ac")

BLUEZ = "org.bluez"
DEVICE_IFACE = "org.bluez.Device1"
PROPS_IFACE = "org.freedesktop.DBus.Properties"

bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
connected_apple = set()
stop_timer = None


def log(msg):
    print(f"librepods-watch: {msg}", file=sys.stderr, flush=True)


def systemctl(verb):
    subprocess.run(["systemctl", "--user", verb, UNIT], check=False)


def is_apple_and_connected(props):
    modalias = props.get("Modalias", "").lower()
    return props.get("Connected", False) and modalias.startswith(APPLE_MODALIAS_PREFIXES)


def cancel_stop():
    global stop_timer
    if stop_timer is not None:
        GLib.source_remove(stop_timer)
        stop_timer = None


def grace_expired():
    global stop_timer
    stop_timer = None
    log(f"no Apple device for {GRACE_SECONDS}s, stopping {UNIT}")
    systemctl("stop")
    return GLib.SOURCE_REMOVE


def update(path, props):
    """Record path's state, then start or schedule the stop as needed."""
    global stop_timer
    if is_apple_and_connected(props):
        if path not in connected_apple:
            log(f"Apple device connected: {path}")
        connected_apple.add(path)
    else:
        connected_apple.discard(path)

    if connected_apple:
        cancel_stop()
        systemctl("start")  # no-op if already active
    elif stop_timer is None and is_unit_active():
        stop_timer = GLib.timeout_add_seconds(GRACE_SECONDS, grace_expired)


def is_unit_active():
    return subprocess.run(["systemctl", "--user", "is-active", "--quiet", UNIT]).returncode == 0


def get_all(path):
    try:
        reply = bus.call_sync(
            BLUEZ, path, PROPS_IFACE, "GetAll",
            GLib.Variant("(s)", (DEVICE_IFACE,)),
            GLib.VariantType("(a{sv})"), Gio.DBusCallFlags.NONE, -1, None,
        )
    except GLib.Error:
        return {}  # device removed in the meantime
    return reply.unpack()[0]


def on_properties_changed(_conn, _sender, path, _iface, _signal, params):
    iface, changed, _invalidated = params.unpack()
    if iface != DEVICE_IFACE:
        return
    # Modalias can be filled in after Connected flips, so re-read everything
    # rather than trusting the delta.
    if "Connected" in changed or "Modalias" in changed:
        update(path, get_all(path))


def on_interfaces_removed(_conn, _sender, _path, _iface, _signal, params):
    path, ifaces = params.unpack()
    if DEVICE_IFACE in ifaces:
        update(path, {})


def initial_scan():
    reply = bus.call_sync(
        BLUEZ, "/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects",
        None, GLib.VariantType("(a{oa{sa{sv}}})"), Gio.DBusCallFlags.NONE, -1, None,
    )
    for path, ifaces in reply.unpack()[0].items():
        if DEVICE_IFACE in ifaces:
            update(path, ifaces[DEVICE_IFACE])


bus.signal_subscribe(
    BLUEZ, PROPS_IFACE, "PropertiesChanged", None, DEVICE_IFACE,
    Gio.DBusSignalFlags.NONE, on_properties_changed,
)
bus.signal_subscribe(
    BLUEZ, "org.freedesktop.DBus.ObjectManager", "InterfacesRemoved", "/", None,
    Gio.DBusSignalFlags.NONE, on_interfaces_removed,
)

try:
    initial_scan()
except GLib.Error as e:
    log(f"bluetoothd not reachable yet ({e.message}); waiting for signals")

GLib.MainLoop().run()
