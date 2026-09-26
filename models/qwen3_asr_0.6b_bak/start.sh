#!/usr/bin/env bash
# Запуск Qwen3-ASR-0.6B сервера (Speech Recognition)
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/qwen3_asr_0.6b/.env
set +a

echo "🚀 Запуск Qwen3-ASR-0.6B сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/qwen3_asr_0.6b/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/qwen3_asr_0.6b/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-qwen3-asr-0.6b"
echo "   Тест: ./test_model.sh qwen3_asr_0.6b"
