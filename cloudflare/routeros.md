## DNS Configuration

> see Cloudflare Terraform

## Router/Firewall Configuration

```text
/ip/firewall/nat add chain=dstnat action=dst-nat to-addresses=172.29.14.100 to-ports=443 protocol=tcp in-interface=ether1-wan dst-port=443 log=yes log-prefix="aqualog" comment="AquaLog proxy (aqualog.home + auth.aqualog.home)"

/ip/firewall/filter add chain=forward action=accept protocol=tcp in-interface=ether1-wan dst-port=443 log=yes log-prefix="aqualog" comment="AquaLog proxy (aqualog.home + auth.aqualog.home)"
```

## PC Firewall Configuration
```powershell
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=443 connectaddress=172.20.2.199 connectport=443

New-NetFirewallRule -DisplayName "Allow TCP 443 to AquaLog" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443
```
