#!/usr/bin/env bash
# Тестирование Qwen3-TTS CustomVoice 1.7B
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/qwen3_tts_customvoice/.env
set +a

OUTPUT_DIR=~/workspace/tmp/vllm_omni_docker_inference_rocm/test_output/qwen3_tts_customvoice
mkdir -p "${OUTPUT_DIR}"

echo "🧪 Тестирование Qwen3-TTS CustomVoice 1.7B (порт ${PORT})..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT}/health" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ Сервер не отвечает (HTTP: ${HTTP_CODE})"
    exit 1
fi
echo "✅ Сервер работает"

echo ""
echo "🎤 Генерация речи (predefined speaker: ryan)..."
START_TIME=$(date +%s)

curl --max-time 300000 -s -o "${OUTPUT_DIR}/test.wav" -w "\nHTTP_CODE:%{http_code}\nSIZE:%{size_download}\nTIME:%{time_total}" \
  -X POST "http://localhost:${PORT}/v1/audio/speech" \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Привет, это тест Hermes модели на vLLM-Omni с ROCm поддержкой. Модель Qwen3-TTS CustomVoice",
    "voice": "ryan",
    "language": "Russian",
    "max_new_tokens": 150,
    "response_format": "wav"
  }' 2>&1

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo "⏱ Время генерации: ${ELAPSED} секунд"

if [ -f "${OUTPUT_DIR}/test.wav" ]; then
    SIZE=$(du -h "${OUTPUT_DIR}/test.wav" | cut -f1)
    echo ""
    echo "📊 Результат:"
    echo "   Файл: ${OUTPUT_DIR}/test.wav"
    echo "   Размер: ${SIZE}"
    
    python3 -c "
import wave
with wave.open('${OUTPUT_DIR}/test.wav', 'rb') as wav:
    ch = wav.getnchannels(); sw = wav.getsampwidth(); fr = wav.getframerate(); nf = wav.getnframes()
    dur = nf / fr
    print(f'   Каналы: {ch}')
    print(f'   Битность: {sw * 8}-bit')
    print(f'   Частота: {fr}Hz')
    print(f'   Длительность: {dur:.1f} сек')
" 2>/dev/null || echo "   ⚠️ Не удалось прочитать WAV свойства"
    
    echo ""
    echo "✅ Qwen3-TTS CustomVoice 1.7B тест пройден!"
else
    echo ""
    echo "❌ Тест не пройден — файл не создан"
    exit 1
fi
