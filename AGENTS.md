# AGENTS.md — Инструкции для AI-агента

## Контекст проекта

**vllm_omni_docker_inference_rocm** — инференс-сервер TTS (Text-to-Speech) на базе vLLM-Omni 0.22.0, развёрнутый через Docker Compose с поддержкой **AMD ROCm** для работы на AMD GPU.

Поддерживает **12 моделей TTS** для сравнения качества синтеза речи на русском языке.

### Конвенции

- **Docker-образ**: `vllm-omni-rocm_v0_22_0:latest` (собирается из Dockerfile)
- **Базовый образ**: `vllm-rocm_v0_22_0_2026_06_26:latest` (из проекта `vllm_inference_docker_rocm`)
- **GPU**: AMD Radeon 780M (gfx1103) — встроенная графика APU Ryzen 7 8700G
- **ROCm**: 6.10.5
- **CUDA**: НЕ используется — только ROCm
- **Модели на хосте**: `/home/hermes/workspace/models/models_tts/`
- **Workspace mount**: `/home/hermes/workspace` → `/workspace` (для ref_audio)
- **Сообщения с пользователем** — на **русском языке**

## Структура проекта

```
vllm_omni_docker_inference_rocm/
├── Dockerfile                 → сборка образа (vllm-omni поверх vLLM ROCm)
├── docker-compose.yaml        → Docker Compose конфигурация (база)
├── .env                       → конфигурация по умолчанию (CosyVoice3)
├── local.env                  → ROCm настройки (критично!)
├── build.sh                   → сборка Docker-образа
├── start.sh / stop.sh         → запуск/остановка CosyVoice3 (legacy)
├── ping.sh / test.sh          → тесты CosyVoice3 (legacy)
├── download_models.sh         → скачивание моделей с HuggingFace
├── start_model.sh             → запуск любой модели
├── stop_model.sh              → остановка любой модели (или all)
├── test_model.sh              → тест любой модели
├── compare_all.sh             → сравнение всех запущенных моделей
├── ref_audio/                 → референсное аудио для voice cloning
│   └── ref_audio.wav          → голос для клонирования
├── models/                    → конфигурации для каждой модели
│   ├── cosyvoice3/
│   ├── qwen3_tts_base/
│   ├── qwen3_tts_customvoice/
│   ├── qwen3_tts_voicedesign/
│   ├── glm_tts/
│   ├── ming_omni_tts/
│   ├── ming_flash_omni/
│   ├── moss_tts_nano/
│   ├── omnivoice/
│   ├── voxcpm2/
│   ├── voxtral_tts/
│   └── fish_speech/
├── README.md
├── INSTALL.md
└── AGENTS.md
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

## Модели

### Поддерживаемые модели

| Модель | Порт | HF репозиторий | Клонирование | Частота | Память |
|--------|------|---------------|-------------|---------|--------|
| CosyVoice3 0.5B | 8092 | FunAudioLLM/Fun-CosyVoice3-0.5B-2512 | ✓ | 24kHz | ~9GB |
| Qwen3-TTS Base 0.6B | 8093 | Qwen/Qwen3-TTS-12Hz-0.6B-Base | ✓ | 24kHz | ~2.4GB |
| Qwen3-TTS CustomVoice 1.7B | 8094 | Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice | ✓ presets | 24kHz | ~4GB |
| Qwen3-TTS VoiceDesign 1.7B | 8095 | Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign | ✓ описание | 24kHz | ~4GB |
| GLM-TTS | 8096 | zai-org/GLM-TTS | ✓ | 24kHz | ~2.4GB |
| Ming-omni-tts 0.5B | 8097 | inclusionAI/Ming-omni-tts-0.5B | ✓ | 24kHz | ~1GB |
| Ming-flash-omni 2.0 | 8098 | Jonathan1909/Ming-flash-omni-2.0 | ✗ caption | 24kHz | ~2GB |
| MOSS-TTS-Nano | 8099 | OpenMOSS-Team/MOSS-TTS-Nano | ✓ | 48kHz | ~0.4GB |
| OmniVoice | 8100 | k2-fsa/OmniVoice | ✓ | 24kHz | ~2GB |
| VoxCPM2 | 8101 | openbmb/VoxCPM2 | ✓ | 48kHz | ~4GB |
| Voxtral TTS | 8102 | mistralai/Voxtral-4B-TTS-2603 | ✓ presets | 24kHz | ~8GB |
| Fish Speech S2 Pro | 8103 | fishaudio/s2-pro | ✓ | 44.1kHz | ~8GB |

### API различия моделей

**CosyVoice3:**
```json
{
  "input": "Текст",
  "task_type": "Base",
  "ref_audio": "file:///workspace/...",
  "ref_text": "Транскрипция"
}
```

**Qwen3-TTS Base:**
```json
{
  "input": "Текст",
  "task_type": "Base",
  "language": "russian",
  "ref_audio": "file:///workspace/...",
  "ref_text": "Транскрипция"
}
```

**Qwen3-TTS CustomVoice:**
```json
{
  "input": "Текст",
  "voice": "ryan",
  "language": "russian"
}
```

**Qwen3-TTS VoiceDesign:**
```json
{
  "input": "Текст",
  "task_type": "VoiceDesign",
  "language": "russian",
  "instructions": "женский голос, спокойный тон"
}
```

**GLM-TTS:**
```json
{
  "input": "Текст",
  "ref_audio": "file:///workspace/...",
  "ref_text": "Транскрипция"
}
```

**MOSS-TTS-Nano (ref_audio в base64):**
```json
{
  "input": "Текст",
  "ref_audio": "data:audio/wav;base64,..."
}
```

## Критические замечания

1. **Загрузка модели ~2 мин** — Stage 0 (talker) + Stage 1 (code2wav).

2. **Первый TTS-запрос ~4 мин на APU** — JIT-компиляция Triton-ядер + MIOpen.
   MIOpen workspace warnings `provided ptr: 0 size: 0` — нормально, не ошибки.

3. **ROCm работает ТОЛЬКО через Docker** — нативная установка vLLM с ROCm не поддерживается.

4. **GPU память** — модель использует два этапа (talker + code2wav) на одной GPU.
   `GPU_MEMORY_UTILIZATION=0.35` для APU. Если ошибка памяти — снизьте до `0.25`.

5. **ref_audio пути** — в API используйте `file:///workspace/...` (путь внутри контейнера).
   Хост-папка `/home/hermes/workspace` монтируется как `/workspace`.

6. **Базовый образ** — требует `vllm-rocm_v0_22_0_2026_06_26:latest` из проекта `vllm_inference_docker_inference_rocm`.

7. **Параметр `language`** — работает только для Qwen3-TTS.

8. **Ограничение длительности** — используйте `max_new_tokens` (~25 токенов/сек):
   - 10 сек → 250, 20 сек → 500, 30 сек → 750, 60 сек → 1500

9. **Скачивание моделей** — используйте `hf download` (надёжно, скачивает все файлы включая LFS).

10. **venv проекта** — `~/workspace/venvs/vllm_omni_docker_inference_rocm/default/` (не использовать venv других проектов!).

## Управление моделями

```bash
# Скачивание
./download_models.sh              # все модели
./download_models.sh GLM-TTS      # одна модель

# Запуск
./start_model.sh <model_name>

# Остановка
./stop_model.sh <model_name>      # одна модель
./stop_model.sh all               # все модели

# Тестирование
./test_model.sh <model_name>      # одна модель
./compare_all.sh                  # все запущенные модели
./compare_all.sh model1 model2    # конкретные модели
```

## Тестирование

Все модели тестируются с:
- **Одним и тем же референсным голосом**: `ref_audio/ref_audio.wav`
- **Одной и той же тестовой фразой**: "Привет, это тестовая фраза для сравнения качества синтеза речи на русском языке."
- **Одинаковыми параметрами**: `max_new_tokens=250` (~10 сек аудио)

Результаты сохраняются в `~/workspace/tmp/vllm_omni_docker_inference_rocm/test_output/`.
