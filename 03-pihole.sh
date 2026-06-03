#!/usr/bin/env bash
#
# 03-pihole.sh
# Install Pi-hole using the official installer, then point it at the local
# Unbound resolver (run 02-unbound.sh first).

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root (sudo)." >&2
  exit 1
fi

echo "[*] Launching the official Pi-hole installer..."
echo "    During setup, you can pick any upstream (it will be overridden)."
echo

# Official installer (review it first at https://install.pi-hole.net if you like)
curl -sSL https://install.pi-hole.net | bash

cat <<'EOF'

[*] Pi-hole installed.

Post-install steps:
  1. Set the admin password:        pihole setpassword
  2. Open the dashboard:            http://<pi-ip>/admin
  3. Settings > DNS:
       - Custom 1 (IPv4):           127.0.0.1#5335
       - Uncheck ALL public upstreams (Google, Cloudflare, etc.)
  4. Add blocklists:                Settings > Lists
       Recommended starters: StevenBlack hosts, OISD basic.
  5. Point your router's DHCP DNS at this Pi's IP so the whole LAN is filtered.

Useful commands:
  pihole -up        # update
  pihole -g         # update gravity (blocklists)
  pihole status
EOF
