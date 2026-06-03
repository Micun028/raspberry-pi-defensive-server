# Raspberry Pi 5 Defensive Security Server

**Purpose**: Lightweight SIEM, VPN, DNS filtering, nftables firewall, and network segmentation on a Raspberry Pi 5.





## Services deployed
- **Wazuh agent** (lightweight SIEM forwarding)
- **Pi‑hole** + **Unbound** (recursive DNS)
- **WireGuard** (VPN server)
- **nftables** (firewall with segmentation rules)
- **Fail2ban** (SSH brute force protection)

## Security hardening notes
 
- SSH: key-only auth, no root login, fail2ban on the sshd jail.
- Firewall: default-deny inbound; SSH and the web/metrics UIs are LAN-only.
  Remote admin goes through WireGuard, not an exposed SSH port.
- DNS rebinding protection is on in Unbound (`private-address` directives).
- Only UDP 51820 (WireGuard) is exposed to the internet via router port-forward.
- Unattended security upgrades keep the base OS patched.


## Repository contents
- `ansible/` – playbook for automated setup
- `configs/nftables.conf` – firewall rules
- `configs/wireguard/server.conf` – VPN config template
- `docs/` – deployment guide

## Pics
<img width="2220" height="723" alt="image" src="https://github.com/user-attachments/assets/a8c20081-df4e-4af6-90db-2e25c965980a" />

*Grafana*

<img width="897" height="498" alt="image" src="https://github.com/user-attachments/assets/f9d1f6df-f5ea-458f-893a-4281a7570a5e" />

*Splunk*

<img width="2297" height="657" alt="image" src="https://github.com/user-attachments/assets/45f0e592-fb83-456c-9d80-21bc691dc1d3" />

*PIHole*

<img width="892" height="309" alt="image" src="https://github.com/user-attachments/assets/4f2881a6-24ba-48a2-ba93-7fcdc8becc4c" />

*Wazuh*

**Network topology**
 
Internet → router → Raspberry Pi 5 (DNS filtering, VPN, HIDS, firewall) → LAN
devices. A remote client connects back in over an encrypted WireGuard tunnel and
its DNS is forced through Pi-hole.

## Example nftables rule (isolate IoT VLAN)
```bash
table inet filter {
    chain forward {
        type filter hook forward priority 0;
        iifname "eth0.10" oifname "eth0" drop  # block IoT to main LAN
    }
} 






