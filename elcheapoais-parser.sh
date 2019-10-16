#! /bin/bash

export PYTHONUNBUFFERED=True

mkdir -p /var/log/elcheapoais

while : ; do
    LOG="/var/log/elcheapoais/parser.$(date +%Y-%m-%dT%H:%M).log"
    elcheapoais-parser > "$LOG" 2>&1
done
