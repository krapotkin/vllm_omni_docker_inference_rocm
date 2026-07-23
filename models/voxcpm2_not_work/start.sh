#!/usr/bin/env bash
# Запуск VoxCPM2 сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/voxcpm2/.env
set +a

echo "🚀 Запуск VoxCPM2 сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/voxcpm2/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/voxcpm2/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-voxcpm2"
echo "   Тест: ./test_model.sh voxcpm2"
