#!/usr/bin/env bash
set -e

# Solicitar token de ngrok
read -p "Introduce tu Ngrok Auth Token: " TOKEN
ngrok config add-authtoken "$TOKEN"

# Levantar túnel hacia n8n
nohup ngrok http 5678 --region=us > /dev/null 2>&1 &
sleep 5

URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
echo "🔗 n8n expuesto en: $URL"

# Reiniciar n8n con la URL pública
export WEBHOOK_URL="$URL"
docker compose down && docker compose up -d
