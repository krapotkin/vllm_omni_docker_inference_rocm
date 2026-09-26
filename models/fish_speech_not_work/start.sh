#!/usr/bin/env bash
# Запуск Fish Speech S2 Pro сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/fish_speech/.env
set +a

echo "🚀 Запуск Fish Speech S2 Pro сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/fish_speech/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/fish_speech/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-fish-speech"
echo "   Тест: ./test_model.sh fish_speech"
