#!/usr/bin/env bash
#
# 02-unbound.sh
# Install and configure Unbound as a local recursive DNS resolver for Pi-hole.
# After this, Pi-hole's upstream DNS should be set to 127.0.0.1#5335.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root (sudo)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "[*] Installing Unbound..."
apt-get update -y
apt-get install -y unbound

echo "[*] Fetching current root hints..."
curl -fsSL https://www.internic.net/domain/named.root \
  -o /var/lib/unbound/root.hints
chown unbound:unbound /var/lib/unbound/root.hints 2>/dev/null || true

echo "[*] Installing Pi-hole resolver config..."
install -m 0644 "$REPO_ROOT/config/unbound/pi-hole.conf" \
  /etc/unbound/unbound.conf.d/pi-hole.conf

echo "[*] Restarting Unbound..."
systemctl enable --now unbound
systemctl restart unbound

echo "[*] Testing resolution via Unbound (127.0.0.1:5335)..."
if command -v dig >/dev/null; then
  dig +short @127.0.0.1 -p 5335 example.com || true
else
  echo "    (install dnsutils to run 'dig' tests)"
fi

echo
echo "[*] Done. Now set Pi-hole upstream DNS to:  127.0.0.1#5335"
echo "    Pi-hole admin > Settings > DNS > Custom 1 (IPv4): 127.0.0.1#5335"
echo "    and UNCHECK all public upstream resolvers."
