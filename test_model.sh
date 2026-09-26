#!/usr/bin/env bash
# Универсальный тест модели TTS
#
# ИСПОЛЬЗОВАНИЕ:
#   ./test_model.sh <model_name>
#
# Доступные модели:
#   cosyvoice3, qwen3_tts_base, qwen3_tts_customvoice, qwen3_tts_voicedesign,
#   glm_tts, ming_omni_tts, ming_flash_omni, moss_tts_nano,
#   omnivoice, voxcpm2, voxtral_tts, fish_speech

set -euo pipefail
cd "$(dirname "$0")"

MODEL="${1:-}"
if [ -z "${MODEL}" ]; then
    echo "❌ Укажите модель:"
    echo "   ./test_model.sh <model_name>"
    echo ""
    echo "Доступные модели:"
    for dir in models/*/; do
        name=$(basename "$dir")
        if [ -f "models/${name}/test.sh" ]; then
            echo "   - ${name}"
        fi
    done
    exit 1
fi

if [ ! -f "models/${MODEL}/test.sh" ]; then
    echo "❌ Модель '${MODEL}' не найдена"
    exit 1
fi

echo "═══════════════════════════════════════"
echo "  Тестирование: ${MODEL}"
echo "═══════════════════════════════════════"
echo ""

bash "models/${MODEL}/test.sh"
