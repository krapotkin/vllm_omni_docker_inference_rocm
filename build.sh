#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "🔨 Сборка Docker-образа vllm-omni-rocm_v0_22_0..."
docker build -t vllm-omni-rocm_v0_22_0:latest .

echo "✅ Образ собран: vllm-omni-rocm_v0_22_0:latest"
docker images vllm-omni-rocm_v0_22_0
