#!/usr/bin/env bash
# Универсальный запуск модели TTS
#
# ИСПОЛЬЗОВАНИЕ:
#   ./start_model.sh <model_name>
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
    echo "   ./start_model.sh <model_name>"
    echo ""
    echo "Доступные модели:"
    for dir in models/*/; do
        name=$(basename "$dir")
        if [ -f "models/${name}/start.sh" ]; then
            echo "   - ${name}"
        fi
    done
    exit 1
fi

if [ ! -f "models/${MODEL}/start.sh" ]; then
    echo "❌ Модель '${MODEL}' не найдена"
    exit 1
fi

echo "═══════════════════════════════════════"
echo "  Запуск: ${MODEL}"
echo "═══════════════════════════════════════"
echo ""

bash "models/${MODEL}/start.sh"
