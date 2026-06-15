#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# Загружаем .env
set -a
source .env
set +a

echo "🚀 Запуск vLLM-Omni TTS сервера (ROCm)..."
docker compose up -d

echo "⏳ Ожидание инициализации сервера..."
sleep 5

# Проверяем статус
docker compose ps

echo ""
echo "✅ Сервер запущен на порту ${PORT:-8092}"
echo "   Логи: docker logs -f vllm-omni-rocm-tts"
echo "   Тест: ./ping.sh"
