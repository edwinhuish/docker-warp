FROM ubuntu:22.04

# install dependencies
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y curl gnupg lsb-release && \
  curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
  apt-get update && \
  apt-get install -y cloudflare-warp && \
  apt-get clean && \
  apt-get autoremove -y && \
  curl -LO https://github.com/ginuerzh/gost/releases/download/v2.11.2/gost-linux-amd64-2.11.2.gz && \
  gunzip gost-linux-amd64-2.11.2.gz && \
  mv gost-linux-amd64-2.11.2 /usr/bin/gost && \
  chmod +x /usr/bin/gost

# Accept Cloudflare WARP TOS
RUN mkdir -p /root/.local/share/warp && \
  echo -n 'yes' > /root/.local/share/warp/accepted-tos.txt

COPY init /init

RUN chmod +x /init

ENV WARP_LICENSE_KEY=
ENV GOST_ARGS="-L :1080"

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS --connect-timeout 1 --max-time 3 "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || exit 1

ENTRYPOINT ["/init"]
