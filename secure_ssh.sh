#!/bin/bash

# secure_ssh.sh - Endurecimiento seguro y automatizable de SSH en Debian 12
# Autor: lalonar
# Repositorio: https://github.com/lalonar/server-hardening/

set -e

echo "[+] Endureciendo SSH..."

# === Configuración por defecto (ajustable vía variables de entorno) ===
NEW_PORT="${SSH_PORT:-2222}"
ALLOW_USERS="${SSH_ALLOW_USERS:-}"  # Ej: "admin,deploy" (opcional)

# Validar puerto
if ! [[ "$NEW_PORT" =~ ^[0-9]+$ ]] || [ "$NEW_PORT" -lt 1 ] || [ "$NEW_PORT" -gt 65535 ]; then
  echo "[!] Puerto inválido: '$NEW_PORT'. Usando puerto por defecto 2222."
  NEW_PORT=2222
fi

# Verificar que exista al menos una clave SSH pública para el usuario actual o root
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
if [ -z "$USER_HOME" ]; then
  USER_HOME="/root"
fi

if [ ! -f "$USER_HOME/.ssh/authorized_keys" ] || [ ! -s "$USER_HOME/.ssh/authorized_keys" ]; then
  echo "[!] ADVERTENCIA: No se encontró ~/.ssh/authorized_keys con claves públicas."
  echo "    Sin acceso por clave, desactivar PasswordAuthentication podría bloquearte."
  echo "    Por seguridad, NO se desactivará la autenticación por contraseña."
  USE_PASSWORD_AUTH="yes"
else
  USE_PASSWORD_AUTH="no"
fi

# Instalar dependencias
apt install -y openssh-server ufw

# Respaldo de configuración original
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d_%H%M%S)

# Aplicar configuración segura
sed -i 's/^#*Port.*/Port '"$NEW_PORT"'/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication '"$USE_PASSWORD_AUTH"'/' /etc/ssh/sshd_config
sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*Protocol.*/Protocol 2/' /etc/ssh/sshd_config

# Opcional: limitar usuarios (si se especificó)
if [ -n "$ALLOW_USERS" ]; then
  grep -q "^AllowUsers" /etc/ssh/sshd_config || echo "AllowUsers $ALLOW_USERS" >> /etc/ssh/sshd_config
  sed -i "s/^AllowUsers.*/AllowUsers $ALLOW_USERS/" /etc/ssh/sshd_config
fi

# Validar configuración antes de reiniciar
if ! sshd -t; then
  echo "[!] Error en la configuración de SSH. Restaurando respaldo..."
  cp /etc/ssh/sshd_config.bak.* /etc/ssh/sshd_config
  exit 1
fi

# Reiniciar SSH
systemctl restart ssh

# Configurar UFW
ufw allow "$NEW_PORT/tcp"
ufw --force enable

echo "[+] SSH endurecido con éxito."
echo "    - Puerto: $NEW_PORT"
echo "    - PermitRootLogin: no"
echo "    - PasswordAuthentication: $USE_PASSWORD_AUTH"
if [ -n "$ALLOW_USERS" ]; then
  echo "    - AllowUsers: $ALLOW_USERS"
fi
echo "    - Firewall (UFW): activo"
echo ""
echo "⚠️  ¡Asegúrate de poder conectarte por clave SSH antes de cerrar esta sesión!"
