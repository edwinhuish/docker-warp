#!/bin/bash

# exit when any command fails
set -e

DEBIAN_FRONTEND=noninteractive

function register_if_need() {
  if [ -f /var/lib/cloudflare-warp/reg.json ]; then
    return
  fi

  # if /var/lib/cloudflare-warp/reg.json not exists, register the warp client
  warp-cli register && echo "Warp client registered!"
  # if a license key is provided, register the license
  if [ -n "$WARP_LICENSE_KEY" ]; then
    echo "License key found, registering license..."
    warp-cli set-license "$WARP_LICENSE_KEY" && echo "Warp license registered!"
  fi
}

while true; do

  if ! warp-cli status 2>/dev/null 1>/dev/null; then

    echo "warp 服务未启动，将在 5 秒后重试"
    sleep 5
    continue

  fi

  break

done

echo "warp 服务启动成功"
# register if need
register_if_need

# connect to the warp server every check make sure is connected
warp-cli connect

# 退出进程
exit 0
