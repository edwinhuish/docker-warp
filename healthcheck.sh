#!/bin/bash

# exit when any command fails
set -e

DEBIAN_FRONTEND=noninteractive

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
  nohup gost $GOST_ARGS &
}

function warp_health_check {

  curl -fsS "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || exit 1

}

# start gost if need
start_gost_if_need

# check warp health
warp_health_check
