#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT=${PORT:-8092}
echo "🔍 Быстрый тест vLLM-Omni (порт ${PORT})..."

# Health check
echo ""
echo "1. Health check:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT}/health" 2>/dev/null || echo "000")
echo "   HTTP: ${HTTP_CODE}"
if [ "$HTTP_CODE" != "200" ]; then
    echo "   ❌ Сервер не отвечает"
    exit 1
fi
echo "   ✅ Сервер работает"

# Проверка моделей
echo ""
echo "2. Доступные модели:"
curl -s "http://localhost:${PORT}/v1/models" 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for m in data.get('data', []):
    print(f\"   - {m.get('id', 'unknown')}\")
" 2>/dev/null || echo "   ⚠️ Не удалось получить список моделей"

echo ""
echo "✅ Быстрый тест пройден"
