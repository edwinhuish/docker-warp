#!/bin/bash

# exit when any command fails
set -e

# create a tun device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# start the daemon
warp-svc &

retries=0

while [ $retries -lt $WARP_MAX_RETRIES ]
do
    # 执行 warp-cli status 命令
    if warp-cli status 2>/dev/null 1>/dev/null; then
        echo "warp 服务启动成功"
        break
    else
        echo "warp 服务未启动，将在 $WARP_RETRY_INTERVAL 秒后重试"
        sleep $WARP_RETRY_INTERVAL
        retries=$((retries+1))
    fi
done

if [ $retries -eq $WARP_MAX_RETRIES ]; then
    echo "warp 服务启动失败，退出程序"
    exit 1
fi


# if /var/lib/cloudflare-warp/reg.json not exists, register the warp client
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
    warp-cli register && echo "Warp client registered!"
    # if a license key is provided, register the license
    if [ -n "$WARP_LICENSE_KEY" ]; then
        echo "License key found, registering license..."
        warp-cli set-license "$WARP_LICENSE_KEY" && echo "Warp license registered!"
    fi
else
    echo "Warp client already registered, skip registration"
fi

# connect to the warp server
warp-cli connect

# start the proxy
gost $GOST_ARGS

ecec "$@"
