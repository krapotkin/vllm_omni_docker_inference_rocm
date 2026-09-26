#!/usr/bin/env bash
# Скачивание всех TTS-моделей для vLLM-Omni
#
# ИСПОЛЬЗОВАНИЕ:
#   source .venv
#   ./download_models.sh              # скачать все
#   ./download_models.sh GLM-TTS      # скачать только одну
#
# Модели сохраняются в ~/workspace/models/models_tts/

set -euo pipefail
cd "$(dirname "$0")"

# Активируем venv проекта
if ! command -v hf &>/dev/null; then
    source .venv
fi

MODELS_DIR="${MODELS_DIR:-/home/hermes/workspace/models/models_tts}"
mkdir -p "${MODELS_DIR}"

# Список моделей: "LOCAL_DIR_NAME hf_repo_path"
declare -A MODELS=(
    ["Fun-CosyVoice3-0.5B-2512"]="FunAudioLLM/Fun-CosyVoice3-0.5B-2512"
    ["Qwen3-TTS-12Hz-0.6B-Base"]="Qwen/Qwen3-TTS-12Hz-0.6B-Base"
    ["Qwen3-TTS-12Hz-1.7B-CustomVoice"]="Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice"
    ["Qwen3-TTS-12Hz-1.7B-VoiceDesign"]="Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign"
    ["GLM-TTS"]="zai-org/GLM-TTS"
    ["Ming-omni-tts-0.5B"]="inclusionAI/Ming-omni-tts-0.5B"
    ["Ming-flash-omni-2.0"]="Jonathan1909/Ming-flash-omni-2.0"
    ["MOSS-TTS-Nano"]="OpenMOSS-Team/MOSS-TTS-Nano"
    ["OmniVoice"]="k2-fsa/OmniVoice"
    ["VoxCPM2"]="openbmb/VoxCPM2"
    ["Voxtral-4B-TTS-2603"]="mistralai/Voxtral-4B-TTS-2603"
    ["s2-pro"]="fishaudio/s2-pro"
)

# ASR модели (сохраняются в ~/workspace/models/models_asr/)
declare -A ASR_MODELS=(
    ["Qwen3-ASR-0.6B"]="Qwen/Qwen3-ASR-0.6B"
)

# Проверяем, указана ли конкретная модель
TARGET="${1:-}"

download_model() {
    local local_name="$1"
    local hf_repo="$2"
    local local_path="${MODELS_DIR}/${local_name}"

    if [ -d "${local_path}" ] && [ -n "$(ls -A "${local_path}" 2>/dev/null)" ]; then
        local size
        size=$(du -sh "${local_path}" 2>/dev/null | cut -f1)
        echo "✅ ${local_name} (${size}) — уже скачана"
        return 0
    fi

    echo ""
    echo "📥 Скачивание: ${local_name} (${hf_repo})"
    echo "   Путь: ${local_path}"

    # Пробуем с retry
    local attempt=0
    local max_attempts=3
    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt + 1))
        echo "   Попытка ${attempt}/${max_attempts}..."

        if hf download "${hf_repo}" --local-dir "${local_path}" 2>&1; then
            local size
            size=$(du -sh "${local_path}" 2>/dev/null | cut -f1)
            echo "✅ ${local_name} скачана (${size})"
            return 0
        fi

        echo "   ❌ Ошибка, повторяю через 10 сек..."
        sleep 10
    done

    echo "❌ Не удалось скачать ${local_name} после ${max_attempts} попыток"
    return 1
}

echo "🎯 Модели TTS для vLLM-Omni"
echo "   Папка: ${MODELS_DIR}"
echo ""

if [ -n "${TARGET}" ]; then
    # Скачать конкретную модель
    if [ -n "${MODELS[${TARGET}]+x}" ]; then
        download_model "${TARGET}" "${MODELS[${TARGET}]}"
    elif [ -n "${ASR_MODELS[${TARGET}]+x}" ]; then
        ASR_MODELS_DIR="${ASR_MODELS_DIR:-/home/hermes/workspace/models/models_asr}"
        mkdir -p "${ASR_MODELS_DIR}"
        local local_path="${ASR_MODELS_DIR}/${TARGET}"
        if [ -d "${local_path}" ] && [ -n "$(ls -A "${local_path}" 2>/dev/null)" ]; then
            local size
            size=$(du -sh "${local_path}" 2>/dev/null | cut -f1)
            echo "✅ ${TARGET} (${size}) — уже скачана"
        else
            echo ""
            echo "📥 Скачивание ASR: ${TARGET} (${ASR_MODELS[${TARGET}]})"
            echo "   Путь: ${local_path}"
            hf download "${ASR_MODELS[${TARGET}]}" --local-dir "${local_path}" 2>&1
            local size
            size=$(du -sh "${local_path}" 2>/dev/null | cut -f1)
            echo "✅ ${TARGET} скачана (${size})"
        fi
    else
        echo "❌ Модель '${TARGET}' не найдена. Доступные:"
        for name in "${!MODELS[@]}"; do
            echo "   - ${name}"
        done
        echo ""
        echo "ASR модели:"
        for name in "${!ASR_MODELS[@]}"; do
            echo "   - ${name}"
        done
        exit 1
    fi
else
    # Скачать все модели
    FAILED=()
    for name in "${!MODELS[@]}"; do
        if ! download_model "${name}" "${MODELS[${name}]}"; then
            FAILED+=("${name}")
        fi
    done

    echo ""
    echo "═══════════════════════════════════════"
    if [ ${#FAILED[@]} -eq 0 ]; then
        echo "✅ Все модели скачаны!"
    else
        echo "⚠️ Не удалось скачать:"
        for f in "${FAILED[@]}"; do
            echo "   - ${f}"
        done
        echo ""
        echo "Попробуйте позже: ./download_models.sh ${FAILED[0]}"
    fi
    echo "═══════════════════════════════════════"
fi
