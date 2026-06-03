# Raspberry Pi 5 Defensive Security Server

**Purpose**: Lightweight SIEM, VPN, DNS filtering, nftables firewall, and network segmentation on a Raspberry Pi 5.

## Services deployed
- **Wazuh agent** (lightweight SIEM forwarding)
- **Pi‑hole** + **Unbound** (recursive DNS)
- **WireGuard** (VPN server)
- **nftables** (firewall with segmentation rules)
- **Fail2ban** (SSH brute force protection)

## Repository contents
- `ansible/` – playbook for automated setup
- `configs/nftables.conf` – firewall rules
- `configs/wireguard/server.conf` – VPN config template
- `docs/` – deployment guide

## Example nftables rule (isolate IoT VLAN)
```bash
table inet filter {
    chain forward {
        type filter hook forward priority 0;
        iifname "eth0.10" oifname "eth0" drop  # block IoT to main LAN
    }
}