#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT=${PORT:-8092}
OUTPUT_DIR=~/workspace/tmp/vllm_omni_docker_inference_rocm/test_output
mkdir -p "${OUTPUT_DIR}"

echo "🧪 Полное тестирование TTS (CosyVoice3)..."
echo "   Порт: ${PORT}"
echo "   Выход: ${OUTPUT_DIR}/test_tts.wav"

# TTS запрос
echo ""
echo "🎤 Генерация речи..."
START_TIME=$(date +%s)

curl -s -o "${OUTPUT_DIR}/test_tts.wav" -w "HTTP_CODE:%{http_code}\nSIZE:%{size_download}\nTIME:%{time_total}" \
  -X POST "http://localhost:${PORT}/v1/audio/speech" \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Привет, это тест CosyVoice3 модели на vLLM-Omni с ROCm поддержкой.",
    "task_type": "Base",
    "ref_audio": "file:///workspace/projects/sgl_omni_tts/ref_audio/ref_audio.wav",
    "ref_text": "Агата Love, Дублер Мужа, Книгу озвучивает Саура Павлине. ты была...",
    "max_new_tokens": 750
  }' 2>&1

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo "⏱ Время генерации: ${ELAPSED} секунд ($((ELAPSED / 60)) мин)"

# Проверка результата
if [ -f "${OUTPUT_DIR}/test_tts.wav" ]; then
    SIZE=$(du -h "${OUTPUT_DIR}/test_tts.wav" | cut -f1)
    echo ""
    echo "📊 Результат:"
    echo "   Файл: ${OUTPUT_DIR}/test_tts.wav"
    echo "   Размер: ${SIZE}"
    
    # Проверяем WAV свойства
    python3 -c "
import wave
import struct

with wave.open('${OUTPUT_DIR}/test_tts.wav', 'rb') as wav:
    channels = wav.getnchannels()
    sample_width = wav.getsampwidth()
    framerate = wav.getframerate()
    n_frames = wav.getnframes()
    duration = n_frames / framerate
    
    print(f\"   Каналы: {channels}\")
    print(f\"   Битность: {sample_width * 8}-bit\")
    print(f\"   Частота: {framerate}Hz\")
    print(f\"   Длительность: {duration:.1f} сек ({duration//60}:{duration%60:02.0f})\")
" 2>/dev/null || echo "   ⚠️ Не удалось прочитать WAV свойства"
    
    echo ""
    echo "✅ TTS тест пройден!"
else
    echo ""
    echo "❌ TTS тест не пройден — файл не создан"
    exit 1
fi
