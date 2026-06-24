#!/usr/bin/env bash

####################################
# @description 使用 skopeo 将 Grafana OTel 验证环境依赖镜像完整同步到阿里云公开镜像仓库
# @example
#   1. brew install skopeo
#   2. skopeo login registry.cn-hangzhou.aliyuncs.com
#   3. ./sync-images.sh
# @author zhengqingya
# @date 2026/6/24
####################################

set -euo pipefail

target_registry="registry.cn-hangzhou.aliyuncs.com"
target_image_registry_prefix="${target_registry}/zhengqing/"

images=(
  "docker.io/grafana/tempo:2.9.0|tempo:2.9.0"
  "docker.io/grafana/loki:3.6.7|loki:3.6.7"
  "docker.io/grafana/grafana:13.1.0|grafana:13.1.0"
  "docker.io/library/busybox:1.38.0|busybox:1.38.0"
  "quay.io/prometheus/prometheus:v3.12.0|prometheus:v3.12.0"
  "quay.io/prometheus-operator/prometheus-config-reloader:v0.92.0|prometheus-config-reloader:v0.92.0"
  "ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s:0.154.0|opentelemetry-collector-k8s:0.154.0"
  "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:2.27.0|opentelemetry-autoinstrumentation-java:2.27.0"
  "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:0.62b1|opentelemetry-autoinstrumentation-python:0.62b1"
)

command -v skopeo >/dev/null 2>&1 || {
  echo "*** [×] 未安装 skopeo，请先执行：brew install skopeo"
  exit 1
}

skopeo login --get-login "${target_registry}" >/dev/null 2>&1 || {
  echo "*** [×] 尚未登录阿里云镜像仓库，请先执行：skopeo login ${target_registry}"
  exit 1
}

for mapping in "${images[@]}"; do
  IFS='|' read -r source_image target_image_name <<< "${mapping}"
  target_image="${target_image_registry_prefix}${target_image_name}"

  echo "*** 同步镜像：${source_image} -> ${target_image}"

  skopeo copy \
    --all \
    --retry-times 3 \
    --image-parallel-copies 2 \
    --remove-signatures \
    "docker://${source_image}" \
    "docker://${target_image}"

  echo "*** [√] 同步完成：${target_image}"
done

echo "*** [√] Grafana OTel 验证环境镜像同步完成"
