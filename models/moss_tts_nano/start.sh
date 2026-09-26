#!/usr/bin/env bash
# Запуск MOSS-TTS-Nano сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/moss_tts_nano/.env
set +a

echo "🚀 Запуск MOSS-TTS-Nano сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/moss_tts_nano/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/moss_tts_nano/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-moss-tts-nano"
echo "   Тест: ./test_model.sh moss_tts_nano"
