#!/usr/bin/env bash
set -euo pipefail

# 1) Instalar Docker y Docker Compose plugin
echo "🚀 Instalando Docker y Docker Compose..."
sudo apt update
sudo apt install -y \
  apt-transport-https ca-certificates curl gnupg lsb-release \
  software-properties-common
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
   https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
echo "✅ Docker y Compose instalados."

# 2) Preparar proyecto y volúmenes
PROJECT_DIR="$HOME/n8n_vps"
echo "📂 Creando carpeta $PROJECT_DIR y volúmenes..."
mkdir -p "$PROJECT_DIR"/{easypanel_data,n8n_data}
chmod 755 "$PROJECT_DIR"/{easypanel_data,n8n_data}

# 3) Descargar docker-compose.yml
cd "$PROJECT_DIR"
echo "🛠️  Descargando docker-compose.yml..."
curl -fsSL \
  https://raw.githubusercontent.com/GeorgeTech20/n8n_vps/main/docker-compose.yml \
  -o docker-compose.yml

# 4) Crear .env con credenciales
echo "🔒 Configura tus credenciales:"
read -p "  Usuario EasyPanel (PANEL_USER): " PANEL_USER
read -s -p "  Contraseña EasyPanel (PANEL_PASSWORD): " PANEL_PASS; echo
read -p "  Usuario n8n (N8N_BASIC_AUTH_USER): " N8N_USER
read -s -p "  Contraseña n8n (N8N_BASIC_AUTH_PASSWORD): " N8N_PASS; echo

PUBLIC_IP="http://$(hostname -I | awk '{print $1}')"

cat > .env <<EOF
PANEL_USER=${PANEL_USER}
PANEL_PASSWORD=${PANEL_PASS}
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=${N8N_USER}
N8N_BASIC_AUTH_PASSWORD=${N8N_PASS}
WEBHOOK_URL=${PUBLIC_IP}:5678
N8N_EDITOR_BASE_URL=${PUBLIC_IP}:5678
EOF

echo "✅ .env creado."

# 5) Levantar los servicios
echo "🐳 Levantando EasyPanel y n8n..."
docker compose up -d

echo
echo "🎉 Instalación completa!"
echo "   • EasyPanel → ${PUBLIC_IP}:9000"
echo "   • n8n       → ${PUBLIC_IP}:5678"
