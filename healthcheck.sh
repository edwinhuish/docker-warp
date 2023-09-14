#!/bin/bash

# exit when any command fails
set -e

if ! warp-cli status 2>/dev/null 1>/dev/null; then
  echo "warp 服务未启动"
  exit 1
fi

: ${GOST_ARGS:="-L :1080"}
: ${HEALTHCHECK_RETRY:=3}

function start_gost_if_need() {
  if pgrep -x "gost" >/dev/null; then
    return
  fi

  # start the proxy
  nohup gost $GOST_ARGS &
}

# 访问链接函数
check_warp_status() {

  # 状态正常，返回 0
  curl -fsS "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" && return 0

  # 状态异常，返回 1
  return 1
}

function warp_health_check {

  # 循环尝试
  for ((attempt = 1; attempt <= $HEALTHCHECK_RETRY; attempt++)); do
    echo "第 $attempt 次 WARP 状态检测。。。"

    # 调用函数检查 Warp 状态
    check_warp_status

    # 如果检查成功，则退出脚本
    if [ $? -eq 0 ]; then
      exit 0
    fi

    # 等待 3 秒
    sleep 3
  done

  # 尝试次数超过限制，kill 进程
  kill 1

}

# start gost if need
start_gost_if_need

# check warp health
warp_health_check
