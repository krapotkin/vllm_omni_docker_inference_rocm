# vLLM-Omni ROCm Docker Image
# Базовый образ с vLLM 0.22.0 + ROCm

FROM vllm-rocm_v0_22_0_2026_06_26:latest

# Устанавливаем vLLM-Omni 0.22.0
RUN pip install --no-cache-dir vllm-omni==0.22.0

# Проверка установки
RUN python -c "import vllm; print(f'vLLM: {vllm.__version__}')" && \
    python -c "import vllm_omni; print(f'vLLM-Omni: {vllm_omni.__version__}')"

# Метаданные
LABEL maintainer="vllm-omni-rocm" \
      version="0.22.0" \
      description="vLLM-Omni TTS inference server with ROCm support"
