#! /bin/bash

export PYTHONUNBUFFERED=True
export ELCHEAPOAIS_DBUS=SessionBus

elcheapoais-downsampler server

echo "Downsampler exited. Press enter to continue."
read X
