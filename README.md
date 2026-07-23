# vLLM-Omni Docker ROCm — TTS инференс-сервер

## Описание

Инференс-сервер TTS (Text-to-Speech) на базе **vLLM-Omni 0.22.0** с поддержкой **AMD ROCm**.
Развёртывание через Docker Compose.

Поддерживает **12 моделей TTS** и **1 модель ASR** для сравнения качества синтеза и распознавания речи на русском языке:

### TTS (Text-to-Speech)

| Модель | Параметры | HF репозиторий | Клонирование | Частота |
|--------|-----------|---------------|-------------|---------|
| CosyVoice3 0.5B | 0.5B | FunAudioLLM/Fun-CosyVoice3-0.5B-2512 | ✓ ref_audio | 24 kHz |
| Qwen3-TTS Base 0.6B | 0.6B | Qwen/Qwen3-TTS-12Hz-0.6B-Base | ✓ ref_audio | 24 kHz |
| Qwen3-TTS CustomVoice 1.7B | 1.7B | Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice | ✓ presets | 24 kHz |
| Qwen3-TTS VoiceDesign 1.7B | 1.7B | Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign | ✓ описание | 24 kHz |
| GLM-TTS | ~1B | zai-org/GLM-TTS | ✓ ref_audio | 24 kHz |
| Ming-omni-tts 0.5B | 0.5B | inclusionAI/Ming-omni-tts-0.5B | ✓ ref_audio | 24 kHz |
| Ming-flash-omni 2.0 | ~1B | Jonathan1909/Ming-flash-omni-2.0 | ✗ caption | 24 kHz |
| MOSS-TTS-Nano | 0.1B | OpenMOSS-Team/MOSS-TTS-Nano | ✓ ref_audio | 48 kHz |
| OmniVoice | ~1B | k2-fsa/OmniVoice | ✓ ref_audio | 24 kHz |
| VoxCPM2 | 2B | openbmb/VoxCPM2 | ✓ ref_audio | 48 kHz |
| Voxtral TTS | 4B | mistralai/Voxtral-4B-TTS-2603 | ✓ presets | 24 kHz |
| Fish Speech S2 Pro | 4B | fishaudio/s2-pro | ✓ ref_audio | 44.1 kHz |

### ASR (Automatic Speech Recognition)

| Модель | Параметры | HF репозиторий | Языки |
|--------|-----------|---------------|-------|
| Qwen3-ASR 0.6B | 0.6B | Qwen/Qwen3-ASR-0.6B | 30 языков + 22 диалекта (вкл. русский) |

## Быстрый старт

```bash
# 1. Скачивание моделей
./download_models.sh              # все модели
./download_models.sh GLM-TTS      # одна модель

# 2. Сборка образа (первый раз)
./build.sh

# 3. Запуск модели
./start_model.sh cosyvoice3       # CosyVoice3
./start_model.sh glm_tts          # GLM-TTS
./start_model.sh moss_tts_nano    # MOSS-TTS-Nano
./start_model.sh qwen3_asr_0.6b   # Qwen3-ASR (распознавание речи)
# ... и т.д.

# 4. Тест модели
./test_model.sh cosyvoice3
./test_model.sh glm_tts
./test_model.sh qwen3_asr_0.6b

# 5. Сравнение всех запущенных моделей
./compare_all.sh
```

> **Скачивание моделей:** используйте `hf download` — скачивает все файлы целиком (включая LFS).
> Старый `huggingface-cli download` устарел. Python-скрипты (`snapshot_download`) ненадёжны.

## Управление моделями

### Запуск

```bash
# Запуск конкретной модели
./start_model.sh <model_name>

# Доступные модели:
#   cosyvoice3, qwen3_tts_base, qwen3_tts_customvoice, qwen3_tts_voicedesign
#   glm_tts, ming_omni_tts, ming_flash_omni, moss_tts_nano
#   omnivoice, voxcpm2, voxtral_tts, fish_speech
```

### Остановка

```bash
# Остановка конкретной модели
./stop_model.sh <model_name>

# Остановка всех моделей
./stop_model.sh all
```

### Тестирование

```bash
# Тест одной модели
./test_model.sh <model_name>

# Сравнение всех запущенных моделей
./compare_all.sh

# Сравнение конкретных моделей
./compare_all.sh cosyvoice3 glm_tts qwen3_tts_base
```

## API — TTS

Каждая модель работает на своём порту. Основные порты:

| Модель | Порт |
|--------|------|
| CosyVoice3 | 8092 |
| Qwen3-TTS Base 0.6B | 8093 |
| Qwen3-TTS CustomVoice 1.7B | 8094 |
| Qwen3-TTS VoiceDesign 1.7B | 8095 |
| GLM-TTS | 8096 |
| Ming-omni-tts | 8097 |
| Ming-flash-omni | 8098 |
| MOSS-TTS-Nano | 8099 |
| OmniVoice | 8100 |
| VoxCPM2 | 8101 |
| Voxtral TTS | 8102 |
| Fish Speech S2 Pro | 8103 |

### Пример запроса (voice cloning)

```bash
curl -X POST http://localhost:8092/v1/audio/speech \
    -H "Content-Type: application/json" \
    -d '{
        "input": "Текст для синтеза.",
        "task_type": "Base",
        "ref_audio": "file:///workspace/projects/vllm_omni_docker_inference_rocm/ref_audio/ref_audio.wav",
        "ref_text": "Транскрипция референсного аудио.",
        "max_new_tokens": 250
    }' --output output.wav
```

### Параметры

| Параметр | Тип | Описание |
|----------|-----|----------|
| `input` | string | Текст для синтеза |
| `task_type` | string | `"Base"` — voice cloning, `"VoiceDesign"` — описание голоса |
| `ref_audio` | string | Путь к аудио: `file:///workspace/...` или HTTP URL |
| `ref_text` | string | Транскрипция референсного аудио |
| `voice` | string | Имя предустановленного голоса (Qwen3-TTS, Voxtral) |
| `language` | string | Язык: `"russian"`, `"english"` и др. (Qwen3-TTS) |
| `instructions` | string | Описание стиля голоса (VoiceDesign, Ming-flash) |
| `max_new_tokens` | integer | Макс. токенов. ~25 tok/sec → 250 ≈ 10 сек |
| `response_format` | string | `wav`, `mp3`, `flac`, `pcm`, `aac`, `opus` |
| `stream` | bool | `true` — PCM поток (требует `response_format: "pcm"`) |

> **Важно:** параметр `language` работает только для Qwen3-TTS. Для CosyVoice3 **не нужен**.

## Структура проекта

```
vllm_omni_docker_inference_rocm/
├── Dockerfile                          # сборка образа
├── docker-compose.yaml                 # базовая конфигурация
├── .env                                # конфигурация по умолчанию
├── local.env                           # ROCm настройки
├── build.sh                            # сборка Docker-образа
├── start.sh / stop.sh                  # запуск/остановка (CosyVoice3)
├── ping.sh / test.sh                   # тесты (CosyVoice3)
├── download_models.sh                  # скачивание моделей
├── start_model.sh                      # запуск любой модели
├── stop_model.sh                       # остановка любой модели
├── test_model.sh                       # тест любой модели
├── compare_all.sh                      # сравнение всех моделей
├── ref_audio/                          # референсное аудио
│   └── ref_audio.wav                   # голос для клонирования
├── models/                             # конфигурации моделей
│   ├── cosyvoice3/
│   │   ├── .env                        # порт, пути
│   │   ├── docker-compose.overlay.yaml # Docker Compose overlay
│   │   ├── start.sh                    # запуск
│   │   └── test.sh                     # тест
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

## Сравнение моделей

Для сравнения качества синтеза речи на русском языке:

1. Запустите нужные модели:
   ```bash
   ./start_model.sh cosyvoice3
   ./start_model.sh glm_tts
   ./start_model.sh qwen3_tts_base
   ```

2. Запустите сравнение:
   ```bash
   ./compare_all.sh
   ```

3. Результаты сохранены в `~/workspace/tmp/vllm_omni_docker_inference_rocm/test_output/`

Все модели используют **один и тот же референсный голос** (`ref_audio/ref_audio.wav`) и **одну и ту же тестовую фразу** для объективного сравнения.

## Требования

- Docker + Docker Compose
- AMD GPU (ROCm)
- Базовый образ: `vllm-rocm_v0_22_0_2026_06_26:latest`
- `huggingface_hub` с CLI (`hf`)

## Примечания

- **Первый запрос ~4 мин на APU** — JIT-компиляция Triton-ядер + MIOpen
- GPU память: `GPU_MEMORY_UTILIZATION=0.35` для APU
- ref_audio пути: `file:///workspace/...` (путь внутри контейнера)
- `max_new_tokens` — ограничивает длину генерации (~25 токенов/сек)
- MIOpen warnings `workspace required` — нормально на APU, не влияют на работу
- Большие модели (Voxtral 4B, Fish S2 Pro 4B) могут не поместиться в память APU
