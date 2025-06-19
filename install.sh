#!/usr/bin/env bash
set -euo pipefail

# 1) Instalar Docker + Docker Compose plugin
sudo apt update
sudo apt install -y \
  apt-transport-https ca-certificates curl gnupg lsb-release \
  software-properties-common docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 2) Crear directorio de datos
mkdir -p "$(pwd)/easypanel_data" "$(pwd)/n8n_data"
chmod 755 "$(pwd)/easypanel_data" "$(pwd)/n8n_data"

# 3) Arrancar con Docker Compose
docker compose up -d

echo "✅ EasyPanel en puerto 9000 y n8n en puerto 5678 levantados."
