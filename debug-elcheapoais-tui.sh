#! /bin/bash

export PYTHONUNBUFFERED=True
export ELCHEAPOAIS_DBUS=SessionBus
export TTGOTERM="$1"

elcheapoais-tui

echo "TUI exited. Press enter to continue."
read X
