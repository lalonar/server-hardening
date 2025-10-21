#!/bin/bash
# secure_ssh.sh - endurecimiento básico del servicio SSH

echo "[*] Endureciendo SSH..."

# Cambiar puerto SSH
read -p "Ingrese nuevo puerto SSH (default 2222): " NEW_PORT
NEW_PORT=${NEW_PORT:-2222}

sudo apt install -y openssh-server ufw

sudo sed -i "s/^#Port.*/Port $NEW_PORT/" /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sudo sed -i 's/^#X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config

sudo systemctl restart ssh

# Configurar UFW
sudo ufw allow "$NEW_PORT/tcp"
sudo ufw enable

echo "[+] SSH endurecido. Puerto actual: $NEW_PORT"
