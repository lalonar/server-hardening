#!/bin/bash
set -e

echo "[*] Instalando CrowdSec..."
sudo apt update && sudo apt install -y crowdsec crowdsec-firewall-bouncer-iptables

echo "[*] Habilitando y arrancando servicios..."
sudo systemctl enable --now crowdsec
sudo systemctl enable --now crowdsec-firewall-bouncer

echo "[*] Verificando colecciones activas..."
sudo cscli collections list | grep -A3 enabled

echo "[*] Instalación finalizada. Métricas:"
sudo cscli metrics
