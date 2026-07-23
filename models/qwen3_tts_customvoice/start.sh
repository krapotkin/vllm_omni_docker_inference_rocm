#!/usr/bin/env bash
# Запуск Qwen3-TTS CustomVoice 1.7B сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/qwen3_tts_customvoice/.env
set +a

echo "🚀 Запуск Qwen3-TTS CustomVoice 1.7B сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/qwen3_tts_customvoice/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/qwen3_tts_customvoice/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-qwen3-tts-customvoice-1.7b"
echo "   Тест: ./test_model.sh qwen3_tts_customvoice"
