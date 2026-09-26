#!/usr/bin/env bash
# Запуск CosyVoice3 TTS сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/cosyvoice3/.env
set +a

echo "🚀 Запуск CosyVoice3 TTS сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/cosyvoice3/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/cosyvoice3/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-cosyvoice3"
echo "   Тест: ./test_model.sh cosyvoice3"
