#!/bin/bash

# auditd_setup.sh
# Instala y configura auditd en Debian 12
# Autor: lalonar
# Repositorio: https://github.com/lalonar/server-hardening/

set -e

echo "[+] Instalando auditd..."

# Actualizar índices de paquetes (opcional)
apt update

# Instalar auditd y dependencias útiles
apt install -y auditd audispd-plugins

# Hacer que el servicio se inicie automáticamente
systemctl enable auditd

# Configuración básica de reglas (sobrescribe /etc/audit/rules.d/99-local.rules)
cat > /etc/audit/rules.d/99-local.rules << 'EOF'
# Reglas básicas de auditoría de seguridad

# Registro de comandos privilegiados
-a always,exit -F arch=b64 -S execve -C uid!=euid -k privileged
-a always,exit -F arch=b32 -S execve -C uid!=euid -k privileged

# Intentos de acceso a archivos sensibles
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Acceso a historial de comandos
-w /home/ -p wa -k home_dirs
-w /root/.bash_history -p wa -k root_history

# Registro de cambios en binarios críticos
-w /bin -p wa -k bin_dir
-w /sbin -p wa -k sbin_dir
-w /usr/bin -p wa -k usr_bin_dir
-w /usr/sbin -p wa -k usr_sbin_dir

# Registro de montajes y desmontajes
-a always,exit -F arch=b64 -S mount -k mount
-a always,exit -F arch=b32 -S mount -k mount

# Registro de cambios en reglas de iptables
-w /sbin/iptables -p x -k iptables
-w /sbin/ip6tables -p x -k ip6tables

# Registro de tiempo del sistema
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -k time_change
-a always,exit -F arch=b64 -S clock_settime -k time_change
-a always,exit -F arch=b32 -S clock_settime -k time_change
-w /etc/localtime -p wa -k time_change

# Registro de eventos de red
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system_locale
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system_locale
-w /etc/issue -p wa -k system_locale
-w /etc/issue.net -p wa -k system_locale
-w /etc/hosts -p wa -k system_locale

# Registro de inicio de sesión y autenticación
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# Fin de reglas
EOF

# Reiniciar auditd para aplicar reglas
echo "[+] Recargando reglas de auditd..."
service auditd reload

# Verificar estado
systemctl is-active --quiet auditd && echo "[+] auditd está activo y funcionando." || echo "[!] auditd no está activo."

echo "[+] auditd instalado y configurado con reglas básicas de seguridad."
echo "    - Reglas guardadas en /etc/audit/rules.d/99-local.rules"
echo "    - Servicio habilitado e iniciado"
