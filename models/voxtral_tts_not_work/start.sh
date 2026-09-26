#!/usr/bin/env bash
# Запуск Voxtral TTS сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/voxtral_tts/.env
set +a

echo "🚀 Запуск Voxtral TTS сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/voxtral_tts/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/voxtral_tts/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-voxtral-tts"
echo "   Тест: ./test_model.sh voxtral_tts"
