#!/usr/bin/env bash
# Запуск GLM-TTS сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/glm_tts/.env
set +a

echo "🚀 Запуск GLM-TTS сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/glm_tts/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/glm_tts/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-glm-tts"
echo "   Тест: ./test_model.sh glm_tts"
