#!/bin/bash
set -e

echo "[*] Preparando entorno para instalar CrowdSec..."

# Dependencias necesarias
sudo apt update
sudo apt install -y curl gnupg lsb-release

echo "[*] Agregando repositorio oficial de CrowdSec..."
curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash

echo "[*] Instalando CrowdSec y el bouncer de firewall..."
sudo apt update
sudo apt install -y crowdsec crowdsec-firewall-bouncer-iptables

echo "[*] Habilitando y arrancando servicios..."
sudo systemctl enable --now crowdsec
sudo systemctl enable --now crowdsec-firewall-bouncer

echo "[*] Verificando colecciones activas..."
sudo cscli collections list | grep -A3 enabled || echo "(sin colecciones instaladas aún)"

echo "[*] Instalación finalizada. Métricas:"
sudo cscli metrics
