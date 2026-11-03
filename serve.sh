#!/bin/sh
# Run inside the dev container. Serves a 1,000,000-byte file on port 8000.
set -e
mkdir -p /tmp/repro
head -c 1000000 /dev/urandom > /tmp/repro/big.bin
exec python3 -m http.server 8000 --bind 0.0.0.0 --directory /tmp/repro
