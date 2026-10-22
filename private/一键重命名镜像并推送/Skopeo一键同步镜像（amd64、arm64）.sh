#!/usr/bin/env bash

####################################
# @description 使用 Skopeo 同步 Linux AMD64、ARM64 到阿里云公开镜像仓库
# @example
#   1. brew install skopeo
#   2. skopeo login registry.cn-hangzhou.aliyuncs.com
#   3. ./Skopeo一键同步镜像（amd64、arm64）.sh
# @author zhengqingya
# @date 2026/6/25
####################################

# 命令执行失败、使用未定义变量或管道中任意命令失败时立即退出。
set -euo pipefail

target_registry="registry.cn-hangzhou.aliyuncs.com"
target_image_registry_prefix="${target_registry}/zhengqing/"
architectures=(amd64 arm64)

# 源镜像|目标镜像名:标签，按需修改；源镜像需要同时提供两个架构。TODO
images=(
  "docker.io/library/mysql:8.0|mysql:8.0"
  "docker.io/livekit/livekit-server:v1.13.10|livekit-server:v1.13.10"
)

command -v skopeo >/dev/null 2>&1 || {
  echo "*** [×] 未安装 skopeo，请先执行：brew install skopeo"
  exit 1
}

[[ "$(skopeo copy --help)" == *"--strip-removed-platforms"* ]] || {
  echo "*** [×] 需要 Skopeo 1.24.0+，请先执行：brew update && brew upgrade skopeo"
  exit 1
}

skopeo login --get-login "${target_registry}" >/dev/null 2>&1 || {
  echo "*** [×] 尚未登录阿里云镜像仓库，请先执行：skopeo login ${target_registry}"
  exit 1
}

echo "*** AMD64、ARM64 镜像同步开始"
echo "*** 同步平台：linux/amd64、linux/arm64，与本机 CPU 架构无关"
echo "*** 目标仓库：${target_image_registry_prefix}"
echo "*** 注意：请提前创建对应的公开镜像仓库，或开启自动创建仓库功能"

for mapping in "${images[@]}"; do
  IFS='|' read -r source_image target_image_name <<< "${mapping}"
  target_image="${target_image_registry_prefix}${target_image_name}"

  echo
  echo "********************************************************************"
  echo "*** 同步镜像：${source_image} -> ${target_image}"

  # 1. 确认源镜像提供两个架构；单架构源不会因平台参数转换成双架构。
  for arch in "${architectures[@]}"; do
    source_platform=$(skopeo --override-os linux --override-arch "${arch}" \
      inspect --no-tags --format '{{.Os}}/{{.Architecture}}' "docker://${source_image}")
    if [[ "${source_platform}" != "linux/${arch}" ]]; then
      echo "*** [×] 源镜像平台为 ${source_platform}，无法同步为 linux/${arch}：${source_image}" >&2
      exit 1
    fi
  done

  # 2. 仅复制指定平台并重写索引，移除 unknown/unknown 构建证明及未选中的平台；不要添加 --all。
  skopeo copy \
    --multi-arch linux/amd64,linux/arm64 \
    --strip-removed-platforms \
    --remove-signatures \
    --retry-times 3 \
    --image-parallel-copies 2 \
    "docker://${source_image}" \
    "docker://${target_image}"

  echo "*** [√] 同步完成：${target_image}"
done

echo "*** [√] 所有镜像同步完成"
