# AquaLog Proxy

This stack terminates TLS on a single public IP and routes by hostname:

- aqualog.home.cylindric.net -> frontend and API
- auth.aqualog.home.cylindric.net -> Authentik

TLS certificates are issued and renewed automatically by Caddy using Let's Encrypt.

## Prerequisites

1. Create the shared Docker network once:

   docker network create aqualog-edge

2. Ensure both DNS records resolve publicly to the proxy host:

   - aqualog.home.cylindric.net
   - auth.aqualog.home.cylindric.net

3. Ensure ports 80 and 443 are reachable from the public internet to the proxy host.

4. Optional: copy .env.example to .env.

## Startup Order

1. Start Authentik:

   docker compose -f authentik/docker-compose.yml up -d

2. Start frontend:

   docker compose -f frontend/docker-compose.yml up -d --build

3. Start backend API:

   docker compose -f backend/docker-compose.yml up -d --build

4. Start proxy:

   docker compose -f proxy/docker-compose.yml up -d

## Certificate Notes

- Caddy stores certificates and ACME account data in Docker named volumes (`caddy_data`, `caddy_config`).
- No manual certificate files are required.

## Routing Notes

- Requests to /api/* on aqualog.home.cylindric.net are proxied to backend.
- Requests to /health on aqualog.home.cylindric.net are proxied to backend.
- All other aqualog.home.cylindric.net requests are served by frontend.
