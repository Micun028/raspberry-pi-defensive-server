#!/usr/bin/env bash
#
# 05-grafana-monitoring.sh
# Install a Grafana + Prometheus + node_exporter monitoring stack so you can
# visualise Pi system metrics, and (optionally) Pi-hole stats.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root (sudo)." >&2
  exit 1
fi

echo "[*] Installing Prometheus and node_exporter (system metrics)..."
apt-get update -y
apt-get install -y prometheus prometheus-node-exporter

echo "[*] Adding Grafana APT repository..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://apt.grafana.com/gpg.key \
  | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
  > /etc/apt/sources.list.d/grafana.list

apt-get update -y
apt-get install -y grafana

echo "[*] Configuring Prometheus to scrape node_exporter..."
cat > /etc/prometheus/prometheus.yml <<'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  # Optional: Pi-hole exporter (see notes below to install)
  # - job_name: 'pihole'
  #   static_configs:
  #     - targets: ['localhost:9617']
EOF

systemctl enable --now prometheus prometheus-node-exporter grafana-server

cat <<'EOF'

[*] Monitoring stack installed.

  Grafana:     http://<pi-ip>:3000   (default login admin / admin — change it!)
  Prometheus:  http://<pi-ip>:9090

Next:
  1. In Grafana: Connections > Data sources > add Prometheus
       URL: http://localhost:9090
  2. Import a dashboard:
       Dashboards > Import > ID 1860  (Node Exporter Full)
  3. (Optional) Pi-hole metrics:
       Install ekofr/pihole-exporter, uncomment the pihole job in
       /etc/prometheus/prometheus.yml, then import Grafana dashboard ID 10176.

See config/grafana/dashboard-notes.md for details.
EOF
