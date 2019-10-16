#! /bin/bash

export PYTHONUNBUFFERED=True

mkdir -p /var/log/elcheapoais

while : ; do
    LOG="/var/log/elcheapoais/config.$(date +%Y-%m-%dT%H:%M).log"
    elcheapoais-config /etc/elcheapoais/config.json > "$LOG" 2>&1
done
