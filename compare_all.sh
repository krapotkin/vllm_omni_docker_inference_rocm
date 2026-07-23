#!/usr/bin/env bash
# Сравнение всех TTS моделей
#
# Запускает тест для каждой модели, которая запущена,
# и выводит сводную таблицу результатов.
#
# ИСПОЛЬЗОВАНИЕ:
#   ./compare_all.sh              # протестировать все запущенные модели
#   ./compare_all.sh model1 model2  # протестировать конкретные модели

set -euo pipefail
cd "$(dirname "$0")"

OUTPUT_DIR=~/workspace/tmp/vllm_omni_docker_inference_rocm/test_output
mkdir -p "${OUTPUT_DIR}"

# Список моделей для тестирования
if [ $# -gt 0 ]; then
    MODELS=("$@")
else
    MODELS=(
        "cosyvoice3"
        "qwen3_tts_base"
        "qwen3_tts_customvoice"
        "qwen3_tts_voicedesign"
        "glm_tts"
        "ming_omni_tts"
        "ming_flash_omni"
        "moss_tts_nano"
        "omnivoice"
        "voxcpm2"
        "voxtral_tts"
        "fish_speech"
    )
fi

echo "═══════════════════════════════════════════════════"
echo "  Сравнение TTS моделей на русском языке"
echo "═══════════════════════════════════════════════════"
echo ""
echo "📋 Модели для тестирования: ${#MODELS[@]}"
echo "📂 Выход: ${OUTPUT_DIR}/"
echo ""

# Таблица результатов
RESULTS_FILE="${OUTPUT_DIR}/compare_results.txt"
echo "│ Модель │ Статус │ Время │ Размер │ Частота │ Длительность │" > "${RESULTS_FILE}"
echo "│────────────────────────────│────────│───────│────────│─────────│──────────────│" >> "${RESULTS_FILE}"

TOTAL=0
PASSED=0
FAILED=0

for MODEL in "${MODELS[@]}"; do
    TOTAL=$((TOTAL + 1))
    
    # Проверяем, запущена ли модель
    PORT=$(grep "^PORT=" "models/${MODEL}/.env" 2>/dev/null | cut -d'=' -f2)
    if [ -z "${PORT}" ]; then
        echo "⚠️ ${MODEL}: не найден .env"
        FAILED=$((FAILED + 1))
        echo "│ ${MODEL} │ ❌ нет конфига │ │ │ │ │" >> "${RESULTS_FILE}"
        continue
    fi
    
    # Быстрый health check
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT}/health" 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" != "200" ]; then
        echo "⏭️  ${MODEL}: сервер не запущен (порт ${PORT})"
        echo "│ ${MODEL} │ ⏭️ не запущена │ │ │ │ │" >> "${RESULTS_FILE}"
        continue
    fi
    
    echo ""
    echo "── ${MODEL} (порт ${PORT}) ──"
    
    # Запускаем тест
    if bash "models/${MODEL}/test.sh" 2>&1 | tail -5; then
        PASSED=$((PASSED + 1))
        
        # Извлекаем информацию о файле
        WAV_FILE=$(ls -t "${OUTPUT_DIR}/${MODEL}_"*.wav 2>/dev/null | head -1)
        if [ -n "${WAV_FILE}" ] && [ -f "${WAV_FILE}" ]; then
            SIZE=$(du -h "${WAV_FILE}" | cut -f1)
            INFO=$(python3 -c "
import wave
with wave.open('${WAV_FILE}', 'rb') as wav:
    print(f'{wav.getframerate()}Hz │ {wav.getnframes()/wav.getframerate():.1f}с')
" 2>/dev/null || echo "N/A │ N/A")
            echo "│ ${MODEL} │ ✅ │ │ ${SIZE} │ ${INFO} │" >> "${RESULTS_FILE}"
        fi
    else
        FAILED=$((FAILED + 1))
        echo "│ ${MODEL} │ ❌ ошибка │ │ │ │ │" >> "${RESULTS_FILE}"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Итого: ${TOTAL} | ✅ ${PASSED} | ❌ ${FAILED}"
echo "═══════════════════════════════════════════════════"

echo ""
echo "📊 Результаты сохранены в: ${RESULTS_FILE}"
echo ""
cat "${RESULTS_FILE}"

echo ""
echo "🎧 Аудиофайлы для сравнения:"
ls -la "${OUTPUT_DIR}"/*.wav 2>/dev/null | awk '{print $9}' | while read f; do
    echo "   - $(basename "$f")"
done
