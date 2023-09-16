#!/bin/bash

# exit when any command fails
set -e

DEBIAN_FRONTEND=noninteractive

if ! pgrep -x "gost" >/dev/null; then
  exit 1
fi

if ! pgrep -x "warp-svc" >/dev/null; then
  exit 1
fi

exit 0
