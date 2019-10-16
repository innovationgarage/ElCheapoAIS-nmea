#! /bin/bash

export PYTHONUNBUFFERED=True

mkdir -p /var/log/elcheapoais

while : ; do
    LOG="/var/log/elcheapoais/downsampler.$(date +%Y-%m-%dT%H:%M).log"
    elcheapoais-downsampler server > "$LOG" 2>&1
done
