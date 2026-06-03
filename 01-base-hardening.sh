#!/usr/bin/env bash
#
# 01-base-hardening.sh
# Base OS hardening for the Raspberry Pi defensive server.
# Tested on Raspberry Pi OS (Bookworm) / Debian 12.
#
# Run as root:  sudo ./01-base-hardening.sh
#
# WARNING: This disables SSH password authentication. Make sure you have
# already added your public key to ~/.ssh/authorized_keys and confirmed you
# can log in with it, or you WILL lock yourself out.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root (sudo)." >&2
  exit 1
fi

echo "[*] Updating package lists and upgrading..."
apt-get update -y
apt-get full-upgrade -y

echo "[*] Installing baseline security packages..."
apt-get install -y \
  unattended-upgrades \
  fail2ban \
  nftables \
  curl \
  ca-certificates \
  gnupg

echo "[*] Enabling automatic security updates..."
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "[*] Hardening SSH configuration..."
SSHD=/etc/ssh/sshd_config
cp -n "$SSHD" "${SSHD}.bak.$(date +%F)" || true
sed -i \
  -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
  -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
  -e 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
  -e 's/^#\?X11Forwarding.*/X11Forwarding no/' \
  "$SSHD"
grep -q '^MaxAuthTries' "$SSHD" || echo 'MaxAuthTries 3' >> "$SSHD"

echo "[*] Enabling fail2ban for sshd..."
cat > /etc/fail2ban/jail.d/sshd.local <<'EOF'
[sshd]
enabled  = true
port     = ssh
maxretry = 4
bantime  = 1h
findtime = 10m
EOF

systemctl enable --now fail2ban
systemctl restart ssh

echo "[*] Done. Reboot recommended."
echo "    Verify key-based SSH login from a SECOND session before closing this one."
