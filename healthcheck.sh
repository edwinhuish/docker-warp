#!/bin/bash

# exit when any command fails
set -e

if ! warp-cli status 2>/dev/null 1>/dev/null; then
  echo "warp 服务未启动"
  exit 1
fi

: ${GOST_ARGS:="-L :1080"}

function start_gost_if_need() {
  if pgrep -x "gost" >/dev/null; then
    return
  fi

  # start the proxy
  gost $GOST_ARGS &
}

function warp_health_check {
  curl -fsS "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || kill 1 && exit 1

  exit 0
}

# start gost if need
start_gost_if_need

# check warp health
warp_health_check
