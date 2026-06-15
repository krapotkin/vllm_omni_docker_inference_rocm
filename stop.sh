#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "🛑 Остановка vLLM-Omni TTS сервера..."
docker compose down
echo "✅ Сервер остановлен"
