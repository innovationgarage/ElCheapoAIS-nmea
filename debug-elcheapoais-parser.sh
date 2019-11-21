#! /bin/bash

export PYTHONUNBUFFERED=True
export ELCHEAPOAIS_DBUS=SessionBus

elcheapoais-parser

echo "Parser exited. Press enter to continue."
read X
