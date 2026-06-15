# vLLM-Omni Docker ROCm — Установка с нуля

## Предварительные требования

1. Docker + Docker Compose установлены
2. AMD GPU с ROCm драйверами
3. Базовый образ vLLM ROCm: `vllm-rocm_v0_22_0_2026_06_26:latest`

## Шаг 1: Скачивание модели

```bash
mkdir -p ~/workspace/models/models_tts/Fun-CosyVoice3-0.5B-2512
cd ~/workspace/models/models_tts/Fun-CosyVoice3-0.5B-2512

# Скачиваем CosyVoice3 0.5B (~9.1 GB, 20 файлов)
hf download FunAudioLLM/Fun-CosyVoice3-0.5B-2512 --local-dir .
```

> **Важно:** используйте `hf download` — это скачивает все файлы модели целиком (включая LFS).
> Старый `huggingface-cli download` устарел и не работает.
> Python-скрипты (`snapshot_download`) ненадёжны — могут пропустить файлы.
> Ожидаемое время: ~13 минут при медленном соединении.

## Шаг 2: Сборка Docker-образа

```bash
cd ~/workspace/projects/vllm_omni_docker_inference_rocm
./build.sh
```

## Шаг 3: Настройка

Проверьте `.env`:
```bash
MODEL_HOST_PATH=/home/hermes/workspace/models/models_tts/Fun-CosyVoice3-0.5B-2512
```

## Шаг 4: Запуск

```bash
./start.sh
```

## Шаг 5: Проверка

```bash
./ping.sh
./test.sh
```

## Повторное развёртывание

Если нужно развернуть с нуля на другой машине:
1. Установите Docker + ROCm
2. Соберите базовый образ `vllm-rocm_v0_22_0_2026_06_26:latest` (проект `vllm_inference_docker_rocm`)
3. Выполните шаги 1-5
