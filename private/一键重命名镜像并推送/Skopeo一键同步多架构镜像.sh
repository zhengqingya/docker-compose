#!/usr/bin/env bash

####################################
# @description 使用 skopeo 将镜像完整同步到阿里云公开镜像仓库
# @example
#   1. brew install skopeo
#   2. skopeo login registry.cn-hangzhou.aliyuncs.com
#   3. ./Skopeo一键同步多架构镜像.sh
# @author zhengqingya
# @date 2026/6/24
####################################

# 命令执行失败、使用未定义变量或管道中任意命令失败时立即退出。
set -euo pipefail

target_registry="registry.cn-hangzhou.aliyuncs.com"
target_image_registry_prefix="${target_registry}/zhengqing/"

# 源镜像|目标镜像名，按需修改。TODO
images=(
  "docker.io/library/mysql:8.0|mysql:8.0"
  "docker.io/prom/prometheus:v2.51.2|prometheus:v2.51.2"
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

echo "*** [√] 所有镜像同步完成"
