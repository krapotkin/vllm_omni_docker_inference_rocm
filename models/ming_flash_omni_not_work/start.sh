#!/usr/bin/env bash
# Запуск Ming-flash-omni-2.0 сервера
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/ming_flash_omni/.env
set +a

echo "🚀 Запуск Ming-flash-omni-2.0 сервера (ROCm)..."
docker compose -f docker-compose.yaml -f models/ming_flash_omni/docker-compose.overlay.yaml up

echo "⏳ Ожидание инициализации сервера..."
sleep 5

docker compose -f docker-compose.yaml -f models/ming_flash_omni/docker-compose.overlay.yaml ps

echo ""
echo "✅ Сервер запущен на порту ${PORT}"
echo "   Логи: docker logs -f vllm-omni-rocm-ming-flash-omni"
echo "   Тест: ./test_model.sh ming_flash_omni"
