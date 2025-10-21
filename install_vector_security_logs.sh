#!/bin/bash

# install_vector_security_logs.sh
# Instala Vector y configura recolección de logs de seguridad:
# - rkhunter
# - auditd
# - crowdsec
# Autor: lalonar
# Repositorio: https://github.com/lalonar/server-hardening/

set -e

echo "[+] Instalando Vector (datadog vector) para centralización de logs..."

# Agregar repositorio de Vector
curl --proto '=https' --tlsv1.2 -sSf https://sh.vector.dev | bash

# Instalar Vector (modo agent)
apt install -y vector

# Crear directorio de configuración personalizada
mkdir -p /etc/vector/security.d

# Configuración de fuentes y sink (destino)
cat > /etc/vector/vector.yaml << 'EOF'
# Vector configuration for security logs
# Destino: ¡CAMBIA ESTO EN EL FUTURO! (Ej: IP de tu Security Onion o ELK)
# Por ahora, los logs se almacenan localmente en disco como respaldo.

data_dir: /var/lib/vector

sources:
  rkhunter_logs:
    type: file
    include:
      - /var/log/rkhunter.log
    read_from: beginning
    multiline:
      mode: halt_before
      pattern: '^\['

  auditd_logs:
    type: file
    include:
      - /var/log/audit/audit.log
    read_from: beginning

  crowdsec_logs:
    type: file
    include:
      - /var/log/crowdsec/crowdsec.log
    read_from: beginning
    multiline:
      mode: halt_before
      pattern: '^\{".*}'  # CrowdSec usa JSON, pero a veces multiline

# Transformación opcional: añadir etiquetas
transforms:
  tag_security_logs:
    type: remap
    inputs:
      - rkhunter_logs
      - auditd_logs
      - crowdsec_logs
    source: |
      .source_type = "security"
      .host = get_env_var("HOSTNAME") ?? "unknown"

# Salida: por ahora a archivo local (¡fácil de cambiar después!)
sinks:
  local_security_archive:
    type: file
    inputs:
      - tag_security_logs
    path: /var/log/vector/security.log
    encoding:
      codec: json

# ⚠️ PARA EL FUTURO: descomenta y ajusta este sink cuando tengas ELK/Security Onion
# elasticsearch_security:
#   type: elasticsearch
#   inputs:
#     - tag_security_logs
#   host: "http://TU_VM_SECURITY_ONION:9200"
#   index: "security-logs-%Y-%m-%d"
#   id_key: .vector.id
#   compression: gzip

EOF

# Asegurar permisos (audit.log requiere lectura por root)
usermod -aG adm vector 2>/dev/null || true
# Si audit.log no es legible, forzar permiso (solo si necesario)
if [ -f /var/log/audit/audit.log ]; then
  setfacl -m u:vector:r /var/log/audit/audit.log 2>/dev/null || chmod o+r /var/log/audit/audit.log 2>/dev/null || true
fi

# Habilitar e iniciar Vector
systemctl enable --now vector

# Verificar estado
if systemctl is-active --quiet vector; then
  echo "[+] Vector instalado y ejecutándose."
  echo "    - Logs de seguridad se archivan en /var/log/vector/security.log (JSON)"
  echo "    - Para enviar a ELK/Security Onion: edita /etc/vector/vector.yaml y reinicia vector"
else
  echo "[!] Vector no se inició correctamente. Revisa 'systemctl status vector'"
  exit 1
fi

echo ""
echo "✅ ¡Listo! Tus logs de seguridad están siendo recolectados."
echo "📝 Próximo paso: cuando actives tu VM de Security Onion, edita /etc/vector/vector.yaml"
echo "   y descomenta el sink 'elasticsearch_security' con la IP correcta."
