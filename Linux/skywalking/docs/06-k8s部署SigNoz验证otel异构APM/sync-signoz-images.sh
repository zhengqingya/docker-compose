#!/usr/bin/env bash

####################################
# @description 使用 skopeo 将 SigNoz 依赖镜像完整同步到阿里云公开镜像仓库
# @example
#   1. brew install skopeo
#   2. skopeo login registry.cn-hangzhou.aliyuncs.com
#   3. ./sync-signoz-images.sh
# @author zhengqingya
# @date 2026/6/24
####################################

# 命令执行失败、使用未定义变量或管道中任意命令失败时立即退出。
set -euo pipefail

target_registry="registry.cn-hangzhou.aliyuncs.com"
target_image_registry_prefix="${target_registry}/zhengqing/"

# 显式维护源镜像和目标镜像映射，避免不同上游命名空间下的镜像发生重名。
images=(
  "docker.io/signoz/signoz:v0.129.0|signoz:v0.129.0"
  "docker.io/signoz/signoz-otel-collector:v0.144.5|signoz-otel-collector:v0.144.5"
  "docker.io/signoz/zookeeper:3.7.1|signoz-zookeeper:3.7.1"
  "docker.io/clickhouse/clickhouse-server:25.5.6|signoz-clickhouse:25.5.6"
  "docker.io/altinity/clickhouse-operator:0.21.2|signoz-clickhouse-operator:0.21.2"
  "docker.io/altinity/metrics-exporter:0.21.2|signoz-metrics-exporter:0.21.2"
  "docker.io/library/alpine:3.18.2|alpine:3.18.2"
  "docker.io/library/busybox:1.35|busybox:1.35"
)

command -v skopeo >/dev/null 2>&1 || {
  echo "*** [×] 未安装 skopeo，请先执行：brew install skopeo"
  exit 1
}

skopeo login --get-login "${target_registry}" >/dev/null 2>&1 || {
  echo "*** [×] 尚未登录阿里云镜像仓库，请先执行：skopeo login ${target_registry}"
  exit 1
}

echo "*** SigNoz 镜像同步开始"
echo "*** 目标仓库：${target_image_registry_prefix}"
echo "*** 注意：请提前创建对应的公开镜像仓库，或开启自动创建仓库功能"

for mapping in "${images[@]}"; do
  IFS='|' read -r source_image target_image_name <<< "${mapping}"
  target_image="${target_image_registry_prefix}${target_image_name}"

  echo
  echo "********************************************************************"
  echo "*** 同步镜像：${source_image} -> ${target_image}"

  # --all 会复制 manifest list 以及其中包含的全部 CPU 架构镜像。
  skopeo copy \
    --all \
    --retry-times 3 \
    --image-parallel-copies 2 \
    --remove-signatures \
    "docker://${source_image}" \
    "docker://${target_image}"

  echo "*** [√] 同步完成：${target_image}"
done

echo
echo "********************************************************************"
echo "*** [√] SigNoz 所需镜像已全部同步完成"
echo "*** 下一步：确认目标仓库允许公开拉取，再逐项修改 values.yaml"
