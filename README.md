# vLLM-Omni Docker ROCm — TTS инференс-сервер

## Описание

Инференс-сервер TTS (Text-to-Speech) на базе **vLLM-Omni 0.22.0** с поддержкой **AMD ROCm**.
Развёртывание через Docker Compose.

Текущая модель: **CosyVoice3 0.5B** — голосовой клонинг, мультиязычный.

## Быстрый старт

```bash
# 0. Скачивание модели (~9.1 GB)
mkdir -p ~/workspace/models/models_tts/Fun-CosyVoice3-0.5B-2512
cd ~/workspace/models/models_tts/Fun-CosyVoice3-0.5B-2512
hf download FunAudioLLM/Fun-CosyVoice3-0.5B-2512 --local-dir .
cd ~/workspace/projects/vllm_omni_docker_inference_rocm

# 1. Сборка образа (первый раз)
./build.sh

# 2. Запуск сервера
./start.sh

# 3. Проверка
./ping.sh

# 4. Тест TTS
./test.sh
```

> **Скачивание модели:** используйте `hf download` — скачивает все файлы целиком (включая LFS).
> Старый `huggingface-cli download` устарел. Python-скрипты (`snapshot_download`) ненадёжны.

## API — TTS

```bash
curl -X POST http://localhost:8092/v1/audio/speech \
    -H "Content-Type: application/json" \
    -d '{
        "input": "Текст для синтеза.",
        "task_type": "Base",
        "ref_audio": "file:///workspace/projects/sgl_omni_tts/ref_audio/ref_audio.wav",
        "ref_text": "Транскрипция референсного аудио.",
        "max_new_tokens": 750
    }' --output output.wav
```

### Параметры

| Параметр | Тип | Описание |
|----------|-----|----------|
| `input` | string | Текст для синтеза |
| `task_type` | string | `"Base"` — voice cloning с ref_audio |
| `ref_audio` | string | Путь к аудио: `file:///workspace/...` или HTTP URL |
| `ref_text` | string | Транскрипция референсного аудио |
| `max_new_tokens` | integer | Макс. токенов (по умолч. 2048). ~25 tok/sec → 750 ≈ 30 сек |
| `response_format` | string | `wav`, `mp3`, `flac`, `pcm`, `aac`, `opus` |
| `stream` | bool | `true` — PCM поток (требует `response_format: "pcm"`) |

> **Важно:** параметр `language` работает только для Qwen3-TTS. Для CosyVoice3 **не нужен**.

## Остановка

```bash
./stop.sh
```

## Требования

- Docker + Docker Compose
- AMD GPU (ROCm)
- Базовый образ: `vllm-rocm_v0_22_0_2026_06_26:latest`

## Примечания

- **Первый запрос ~4 мин на APU** — JIT-компиляция Triton-ядер + MIOpen
- GPU память: `GPU_MEMORY_UTILIZATION=0.35` для APU
- ref_audio пути: `file:///workspace/...` (путь внутри контейнера)
- `max_new_tokens` — ограничивает длину генерации (~25 токенов/сек для CosyVoice3)
- MIOpen warnings `workspace required` — нормально на APU, не влияют на работу
