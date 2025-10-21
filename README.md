# Server Hardening Scripts

Conjunto de scripts para endurecimiento básico de Debian 12 en entornos virtualizados (Proxmox, LXC, KVM)

## CrowdSec
curl -s https://raw.githubusercontent.com/lalonar/server-hardening/main/install_crowdsec.sh | bash

## Secure ssh
curl -s https://raw.githubusercontent.com/lalonar/server-hardening/main/secure_ssh.sh | bash


## Rkhunter
curl -s https://raw.githubusercontent.com/lalonar/server-hardening/main/install_rkhunter.sh | sudo bash

## Auditd
curl -s https://raw.githubusercontent.com/lalonar/server-hardening/main/auditd_setup.sh | sudo bash

## Fail2ban
curl -s https://raw.githubusercontent.com/lalonar/server-hardening/main/isntall_fail2ban.sh | bash
