#!/usr/bin/env bash
# Остановка конкретной модели TTS
#
# ИСПОЛЬЗОВАНИЕ:
#   ./stop_model.sh <model_name>
#   ./stop_model.sh all    # остановить все

set -euo pipefail
cd "$(dirname "$0")"

MODEL="${1:-}"
if [ -z "${MODEL}" ]; then
    echo "❌ Укажите модель или 'all':"
    echo "   ./stop_model.sh <model_name>"
    echo "   ./stop_model.sh all"
    exit 1
fi

stop_model() {
    local name="$1"
    local container_name
    container_name=$(grep "container_name:" "models/${name}/docker-compose.overlay.yaml" 2>/dev/null | awk '{print $2}')
    
    if [ -z "${container_name}" ]; then
        echo "⚠️ Не удалось найти контейнер для ${name}"
        return
    fi
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "🛑 Остановка ${container_name}..."
        docker stop "${container_name}" 2>/dev/null || true
        docker rm "${container_name}" 2>/dev/null || true
        echo "✅ ${name} остановлена"
    else
        echo "✅ ${name} уже остановлена"
    fi
}

if [ "${MODEL}" = "all" ]; then
    echo "🛑 Остановка всех TTS серверов..."
    echo ""
    for dir in models/*/; do
        name=$(basename "$dir")
        if [ -f "models/${name}/docker-compose.overlay.yaml" ]; then
            stop_model "${name}"
        fi
    done
else
    if [ ! -d "models/${MODEL}" ]; then
        echo "❌ Модель '${MODEL}' не найдена"
        exit 1
    fi
    stop_model "${MODEL}"
fi
