#!/bin/bash

# install_rkhunter.sh
# Instala y configura rkhunter en Debian 12
# Autor: lalonar
# Repositorio: https://github.com/lalonar/server-hardening/

set -e

echo "[+] Instalando rkhunter..."

# Actualizar índices de paquetes (opcional, pero recomendado)
apt update

# Instalar rkhunter
apt install -y rkhunter

# Inicializar la base de datos de firmas
echo "[+] Inicializando base de datos de rkhunter..."
rkhunter --update
rkhunter --propupd

# Configurar actualizaciones automáticas y escaneos diarios
cat > /etc/cron.daily/rkhunter-scan << 'EOF'
#!/bin/bash
/usr/bin/rkhunter --cronjob --update --quiet
EOF

chmod +x /etc/cron.daily/rkhunter-scan

echo "[+] rkhunter instalado y configurado."
echo "    - Base de datos actualizada"
echo "    - Escaneo diario programado en /etc/cron.daily/rkhunter-scan"
