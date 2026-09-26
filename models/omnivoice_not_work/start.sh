#!/usr/bin/env bash
# Запуск OmniVoice сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/omnivoice/.env
set +a

echo "🚀 Запуск OmniVoice сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/omnivoice/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/omnivoice/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-omnivoice"
echo "   Тест: ./test_model.sh omnivoice"
