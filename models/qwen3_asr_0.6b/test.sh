#!/usr/bin/env bash
# Тестирование Qwen3-ASR-0.6B (распознавание речи с указанием языка)
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source models/qwen3_asr_0.6b/.env
set +a

OUTPUT_DIR=~/workspace/tmp/vllm_omni_docker_inference_rocm/test_output/qwen3_asr_0.6b
mkdir -p "${OUTPUT_DIR}"

# URL аудиофайла (file:// внутри контейнера)
AUDIO_URL="file:///workspace/projects/vllm_omni_docker_inference_rocm/ref_audio/ref_audio.wav"

echo "🧪 Тестирование Qwen3-ASR-0.6B с указанием языка (порт ${PORT})..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT}/health" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ Сервер не отвечает (HTTP: ${HTTP_CODE})"
    exit 1
fi
echo "✅ Сервер работает"

echo ""
echo "🎤 Распознавание речи (язык: Russian)..."
START_TIME=$(date +%s)

curl --max-time 300 -s -o "${OUTPUT_DIR}/result_with_prompt.json" -w "\nHTTP_CODE:%{http_code}\nTIME:%{time_total}" \
  -X POST "http://localhost:${PORT}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{
    \"messages\": [
      {
        \"role\": \"system\",
        \"content\": \"<|ASR|>\\n<|lang|>Russian\"
      },
      {
        \"role\": \"user\",
        \"content\": [
          {
            \"type\": \"audio_url\",
            \"audio_url\": {\"url\": \"${AUDIO_URL}\"}
          }
        ]
      }
    ]
  }" 2>&1

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo "⏱ Время распознавания: ${ELAPSED} секунд"

if [ -f "${OUTPUT_DIR}/result_with_prompt.json" ]; then
    echo ""
    echo "📊 Результат:"
    echo "   Файл: ${OUTPUT_DIR}/result_with_prompt.json"
    
    # Извлекаем текст распознавания
    python3 -c "
import json
with open('${OUTPUT_DIR}/result_with_prompt.json', 'r') as f:
    data = json.load(f)
    content = data.get('choices', [{}])[0].get('message', {}).get('content', 'N/A')
    print(f'   Распознанный текст:')
    print(f'   {content}')
" 2>/dev/null || cat "${OUTPUT_DIR}/result_with_prompt.json"
    
    echo ""
    echo "✅ Qwen3-ASR-0.6B тест пройден!"
else
    echo ""
    echo "❌ Тест не пройден — файл не создан"
    exit 1
fi
