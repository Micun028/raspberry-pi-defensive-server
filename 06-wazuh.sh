#!/usr/bin/env bash
#
# 06-wazuh.sh
# Wazuh setup helper. Two deployment options are documented below — pick one.
#
# A Raspberry Pi 5 (8 GB) can run the full single-node Wazuh stack, but the
# indexer (OpenSearch) is RAM-hungry. For a snappier homelab, run the AGENT on
# the Pi and the MANAGER + DASHBOARD on a more powerful host (or a VM).
# THIS is wazuh agent
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root (sudo)." >&2
  exit 1
fi

MODE="${1:-}"

case "$MODE" in
  manager)
    echo "[*] Installing the all-in-one Wazuh server (manager + indexer + dashboard)."
    echo "    Recommended only on 8 GB RAM. This downloads the official installer."
    curl -sO https://packages.wazuh.com/4.x/wazuh-install.sh
    bash ./wazuh-install.sh -a
    echo
    echo "[*] When finished, the installer prints the dashboard URL and the"
    echo "    admin password. Dashboard: https://<pi-ip>  (port 443)."
    ;;

  agent)
    echo "[*] Installing the Wazuh AGENT. Set WAZUH_MANAGER to your manager's IP."
    : "${WAZUH_MANAGER:?Set WAZUH_MANAGER, e.g. WAZUH_MANAGER=192.168.1.50 ./06-wazuh.sh agent}"
    curl -fsSL https://packages.wazuh.com/key/GPG-KEY-WAZUH \
      | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
      > /etc/apt/sources.list.d/wazuh.list
    apt-get update -y
    WAZUH_MANAGER="$WAZUH_MANAGER" apt-get install -y wazuh-agent
    systemctl daemon-reload
    systemctl enable --now wazuh-agent
    echo "[*] Agent installed and pointed at manager $WAZUH_MANAGER."
    ;;

  *)
    cat <<'EOF'
Usage:
  sudo ./06-wazuh.sh manager
      Install the full Wazuh server stack on this Pi (8 GB RAM recommended).

  sudo WAZUH_MANAGER=<manager-ip> ./06-wazuh.sh agent
      Install only the Wazuh agent and report to an external manager.

Docs: https://documentation.wazuh.com
EOF
    exit 1
    ;;
esac
