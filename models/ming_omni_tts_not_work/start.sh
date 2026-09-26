#!/usr/bin/env bash
# Запуск Ming-omni-tts 0.5B сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/ming_omni_tts/.env
set +a

echo "🚀 Запуск Ming-omni-tts 0.5B сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/ming_omni_tts/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/ming_omni_tts/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-ming-omni-tts"
echo "   Тест: ./test_model.sh ming_omni_tts"
