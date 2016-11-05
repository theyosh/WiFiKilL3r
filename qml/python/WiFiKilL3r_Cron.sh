#!/bin/bash

# Dirty hacks... :(
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/100000/dbus/user_bus_socket
export DBUS_SESSION_BUS_ADDRESS
/usr/bin/python3 /usr/share/WiFiKilL3r/qml/python/WiFiKilL3r.py -a run_check >> /dev/null
exit 0
