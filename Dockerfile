FROM edwinhuish/warp:20230918-100341

COPY init /init
RUN chmod +x /init

ENV WARP_LICENSE_KEY=
ENV GOST_ARGS="-L :1080"

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS --connect-timeout 1 --max-time 3 "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || warp-cli connect; exit 1

ENTRYPOINT ["/init"]
