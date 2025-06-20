#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Configurando ngrok..."

# 1) Solicitar token y crear túnel
read -p "Introduce tu Ngrok Auth Token: " NGROK_TOKEN
ngrok config add-authtoken "$NGROK_TOKEN"

# 2) Arrancar túnel hacia n8n
echo "🔌 Levantando túnel ngrok..."
nohup ngrok http 5678 --region=us > /dev/null 2>&1 &
sleep 5

# 3) Obtener URL pública
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
echo "🔗 n8n expuesto en: $NGROK_URL"

# 4) Reiniciar n8n con la nueva URL
echo "♻️ Reiniciando n8n con nueva URL..."
export WEBHOOK_URL="$NGROK_URL"
export N8N_EDITOR_BASE_URL="$NGROK_URL"
docker compose down
docker compose up -d

echo "✅ ngrok configurado y n8n reiniciado."
