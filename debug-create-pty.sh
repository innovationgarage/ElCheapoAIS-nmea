#! /bin/bash

socat -d -d pty,raw,echo=0 pty,raw,echo=0 2>&1 | tee "$1"

echo "Socat exited. Press enter to continue."
read X
