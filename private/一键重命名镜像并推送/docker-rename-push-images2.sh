#!/bin/bash

####################################
# @description 一键重命名镜像并推送到指定仓库中
# @params $? => 代表上一个命令执行后的退出状态: 0->成功,1->失败
# @example => sh docker-rename-push-images.sh
# @author zhengqingya
# @date 2022/11/8 10:26
####################################

# 在执行过程中若遇到使用了未定义的变量或命令返回值为非零，将直接报错退出
set -eu

# TODO 根据自己的需求进行替换...
# 源镜像
images=(
  mongo:7.0
  prom/prometheus:v2.51.2
)

# 目标镜像仓库
target_image_registry_prefix="registry.cn-hangzhou.aliyuncs.com/zhengqing/"

# 循环
for image in ${images[@]} ; do
  # 获取不含命名空间的镜像名:标签格式
  image_name_tag="${image##*/}"  # 去掉命名空间部分，保留镜像名:标签
  target_image=${target_image_registry_prefix}${image_name_tag}

  # 拉取源镜像
  docker pull ${image}

  # 重命名镜像
  docker tag ${image} ${target_image}

  # 推送镜像
  docker push ${target_image}

  echo "*** [√] 原始镜像: ${image}, 目标镜像: ${target_image}"
done

echo "finish ..."
