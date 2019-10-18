#! /bin/bash

export PYTHONUNBUFFERED=True
export TTGOTERM=/dev/console

mkdir -p /var/log/elcheapoais

while : ; do
    LOG="/var/log/elcheapoais/parser.$(date +%Y-%m-%dT%H:%M).log"
    elcheapoais-tui > "$LOG" 2>&1
done
