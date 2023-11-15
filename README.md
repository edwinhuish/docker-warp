# warp-docker

Run official [Cloudflare WARP](https://1.1.1.1/) client in Docker.

## Usage

### Start the container

To run the WARP client in Docker, just write the following content to `docker-compose.yml` and run `docker-compose up -d`.

```yaml
version: '3'

services:
  warp:
    image: edwinhuish/warp
    container_name: warp
    restart: unless-stopped
    ports:
      - '1080:1080'
    environment:
      # - WARP_PROXY_PORT=1080 # optional
      # - WARP_LICENSE_KEY= # optional
    cap_add:
      - NET_ADMIN
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv4.conf.all.src_valid_mark=1
    volumes:
      - ./data:/var/lib/cloudflare-warp
```

Try it out to see if it works:

```bash
curl --socks5 127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace
```

If the output contains `warp=on` or `warp=plus`, the container is working properly. If the output contains `warp=off`, it means that the container failed to connect to the WARP service.

### Configuration

You can configure the container through the following environment variables:

- `WARP_LICENSE_KEY`: The license key of the WARP client, which is optional. If you have subscribed to WARP+ service, you can fill in the key in this environment variable. If you have not subscribed to WARP+ service, you can ignore this environment variable.

- `WARP_PROXY_PORT`: The socks5 port, default is 1080.
  
Data persistence: Use the host volume `./data` to persist the data of the WARP client. You can change the location of this directory or use other types of volumes. If you modify the `WARP_LICENSE_KEY`, please delete the `./data` directory so that the client can detect and register again.
