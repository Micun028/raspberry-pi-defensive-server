#!/usr/bin/env bash
#
# 04-wireguard.sh
# Install WireGuard, enable IP forwarding, and generate the server keypair.
# You still edit /etc/wireguard/wg0.conf afterwards (see config/wireguard).

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root (sudo)." >&2
  exit 1
fi

echo "[*] Installing WireGuard..."
apt-get update -y
apt-get install -y wireguard wireguard-tools

echo "[*] Enabling IPv4 forwarding..."
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf

echo "[*] Generating server keypair in /etc/wireguard/..."
umask 077
cd /etc/wireguard
if [[ ! -f server_private.key ]]; then
  wg genkey | tee server_private.key | wg pubkey > server_public.key
fi

echo
echo "[*] Server public key (give this to clients):"
cat /etc/wireguard/server_public.key
echo
echo "[*] Next steps:"
echo "    1. Copy config/wireguard/wg0.conf.example to /etc/wireguard/wg0.conf"
echo "    2. Paste in the server private key and your peers' public keys"
echo "    3. chmod 600 /etc/wireguard/wg0.conf"
echo "    4. systemctl enable --now wg-quick@wg0"
echo "    5. Forward UDP 51820 on your router to this Pi"
echo
echo "    Check status with:  wg show"
