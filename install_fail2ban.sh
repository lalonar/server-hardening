#!/bin/bash
set -e

echo "[*] Instalando Fail2ban..."
sudo apt update && sudo apt install -y fail2ban

echo "[*] Copiando configuración local..."
sudo mkdir -p /etc/fail2ban/jail.d
sudo cp jail_local.conf /etc/fail2ban/jail.d/local.conf

echo "[*] Habilitando y reiniciando servicio..."
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

echo "[+] Instalación completada. Estado actual:"
sudo fail2ban-client status
