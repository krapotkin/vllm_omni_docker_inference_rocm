#!/usr/bin/env bash
# Запуск Qwen3-TTS Base 0.6B сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/qwen3_tts_base/.env
set +a

echo "🚀 Запуск Qwen3-TTS Base 0.6B сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/qwen3_tts_base/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/qwen3_tts_base/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-qwen3-tts-base-0.6b"
echo "   Тест: ./test_model.sh qwen3_tts_base"
