# AGENTS.md — Инструкции для AI-агента

## Контекст проекта

**vllm_omni_docker_inference_rocm** — инференс-сервер TTS (Text-to-Speech) на базе vLLM-Omni 0.22.0, развёрнутый через Docker Compose с поддержкой **AMD ROCm** для работы на AMD GPU.

### Конвенции

- **Docker-образ**: `vllm-omni-rocm_v0_22_0:latest` (собирается из Dockerfile)
- **Базовый образ**: `vllm-rocm_v0_22_0_2026_06_26:latest` (из проекта `vllm_inference_docker_rocm`)
- **GPU**: AMD Radeon 780M (gfx1103) — встроенная графика APU Ryzen 7 8700G
- **ROCm**: 6.10.5
- **CUDA**: НЕ используется — только ROCm
- **Настройки**: `local.env` (ROCm параметры) + `.env` (конфигурация)
- **Модель внутри контейнера**: `/models/Fun-CosyVoice3-0.5B-2512`
- **Модель на хосте**: `/home/hermes/workspace/models/models_tts/Fun-CosyVoice3-0.5B-2512`
- **Workspace mount**: `/home/hermes/workspace` → `/workspace` (для ref_audio)
- **Порт**: 8092 (на хосте), 8000 (в контейнере)
- **Сообщения с пользователем** — на **русском языке**

## Структура проекта

```
vllm_omni_docker_inference_rocm/
├── Dockerfile                 → сборка образа (vllm-omni поверх vLLM ROCm)
├── docker-compose.yaml        → Docker Compose конфигурация
├── .env                       → конфигурация (порт, пути, GPU память)
├── local.env                  → ROCm настройки (критично!)
├── build.sh                   → сборка Docker-образа
├── start.sh                   → запуск сервера
├── stop.sh                    → остановка сервера
├── ping.sh                    → быстрый тест (health + модели)
├── test.sh                    → полное тестирование (TTS генерация)
├── README.md                  → запуск, использование, API
├── INSTALL.md                 → установка с нуля
├── AGENTS.md                  → ← этот файл
└── .gitignore
```

## ROCm настройки (local.env)

```bash
SDL_VIDEODRIVER=dummy
VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
VLLM_USE_TRITON_FLASH_ATTN=0
PYTORCH_ROCM_ARCH=gfx1103
HSA_OVERRIDE_GFX_VERSION=11.0.0
FLASH_ATTENTION_TRITON_AMD_ENABLE=TRUE
```

**ВАЖНО:** `HSA_OVERRIDE_GFX_VERSION=11.0.0` и `PYTORCH_ROCM_ARCH=gfx1103` — обязательны для AMD GPU.

## Конфигурация (.env)

```bash
DOCKER_IMAGE=vllm-omni-rocm_v0_22_0:latest
PORT=8092
MODEL_HOST_PATH=/home/hermes/workspace/models/models_tts/Fun-CosyVoice3-0.5B-2512
WORKSPACE_PATH=/home/hermes/workspace
GPU_MEMORY_UTILIZATION=0.35
```

## Критические замечания

1. **Загрузка модели ~2 мин** — Stage 0 (talker) + Stage 1 (code2wav).

2. **Первый TTS-запрос ~4 мин на APU** — JIT-компиляция Triton-ядер + MIOpen.
   MIOpen workspace warnings `provided ptr: 0 size: 0` — нормально, не ошибки.
   На дискретной GPU значительно быстрее.

3. **ROCm работает ТОЛЬКО через Docker** — нативная установка vLLM с ROCm не поддерживается.

4. **GPU память** — модель использует два этапа (talker + code2wav) на одной GPU.
   `GPU_MEMORY_UTILIZATION=0.35` для APU. Если ошибка памяти — снизьте до `0.25`.

5. **ref_audio пути** — в API используйте `file:///workspace/...` (путь внутри контейнера).
   Хост-папка `/home/hermes/workspace` монтируется как `/workspace`.

6. **Базовый образ** — требует `vllm-rocm_v0_22_0_2026_06_26:latest` из проекта `vllm_inference_docker_rocm`.

7. **CosyVoice3** — требует `task_type: "Base"` с `ref_audio` и `ref_text`.

8. **Параметр `language`** — работает только для Qwen3-TTS. Для CosyVoice3 **не нужен**.

9. **Ограничение длительности** — используйте `max_new_tokens` (~25 токенов/сек):
   - 10 сек → 250, 20 сек → 500, 30 сек → 750, 60 сек → 1500

10. **Скачивание моделей** — используйте `hf download` (надёжно, скачивает все файлы включая LFS).
    `huggingface-cli download` устарел, `snapshot_download` пропускает файлы.

## Запуск

```bash
cd ~/workspace/projects/vllm_omni_docker_inference_rocm
./build.sh    # сборка образа (первый раз)
./start.sh    # запуск сервера
./ping.sh     # проверка
```

## API — TTS (Base task)

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

## Тестирование

```bash
./ping.sh              # быстрый тест
./test.sh              # полное тестирование
```
