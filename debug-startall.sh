#! /bin/bash

set -x

PTYFILE="$(mktemp)"
SCREEN="$(basename "$PTYFILE")"

screen -d -m -S $SCREEN ./debug-elcheapoais-config.sh

screen -S $SCREEN -X screen ./debug-create-pty.sh "$PTYFILE"
while ! grep "starting data transfer loop" "$PTYFILE"; do sleep 1; done
PTY1=$(grep "PTY is" "$PTYFILE" | sed -e "s+.*PTY is ++g" | head -1 | tail -1)
PTY2=$(grep "PTY is" "$PTYFILE" | sed -e "s+.*PTY is ++g" | head -2 | tail -1)

screen -S $SCREEN -X screen ./debug-elcheapoais-parser.sh
screen -S $SCREEN -X screen ./debug-elcheapoais-downsampler.sh
screen -S $SCREEN -X screen ./debug-elcheapoais-tui.sh "$PTY1"
screen -S $SCREEN -X screen "$PTY2" 115200

screen -S $SCREEN -ls

screen -r $SCREEN
