#!/bin/bash

# harden_debian.sh
# Script unificado de endurecimiento para Debian 12
# Autor: lalonar
# Repositorio: https://github.com/lalonar/server-hardening/

set -e

BASE_URL="https://raw.githubusercontent.com/lalonar/server-hardening/main"

echo "🔒 Iniciando endurecimiento de sistema..."

# 1. Asegurar SSH (solo si tu script hace más que cambiar puerto)
echo "[+] Aplicando configuración segura de SSH..."
curl -s "$BASE_URL/secure_ssh.sh" | bash

# 2. Instalar CrowdSec (reemplaza a fail2ban)
echo "[+] Instalando CrowdSec..."
curl -s "$BASE_URL/install_crowdsec.sh" | bash

# 3. Instalar rkhunter
echo "[+] Instalando rkhunter..."
curl -s "$BASE_URL/install_rkhunter.sh" | bash

# 4. Configurar auditd
echo "[+] Configurando auditd..."
curl -s "$BASE_URL/auditd_setup.sh" | bash

# 5. Instalar Vector para recolección de logs
echo "[+] Instalando Vector para centralización de logs..."
curl -s "$BASE_URL/install_vector_security_logs.sh" | bash

echo ""
echo "✅ Endurecimiento completado."
echo "   - SSH seguro (sin root, sin password)"
echo "   - CrowdSec activo (detección + bloqueo)"
echo "   - rkhunter: escaneos diarios"
echo "   - auditd: auditoría del kernel"
echo "   - Vector: logs listos para centralizar"
echo ""
echo "⚠️  Recuerda: ¡revisa los logs periódicamente!"
