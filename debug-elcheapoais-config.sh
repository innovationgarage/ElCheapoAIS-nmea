#! /bin/bash

export PYTHONUNBUFFERED=True
export ELCHEAPOAIS_DBUS=SessionBus

elcheapoais-config debug-config.json

echo "Config exited. Press enter to continue."
read X
