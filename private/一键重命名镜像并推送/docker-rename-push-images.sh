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
  mysql:5.7
  nacos-server:2.0.3
)

# 源镜像仓库
source_image_registry_prefix="registry.cn-hangzhou.aliyuncs.com/zhengqing/"
# 目标镜像仓库
target_image_registry_prefix="registry.cn-hangzhou.aliyuncs.com/zhengqing/test-"

# 循环
for image_name in ${images[@]} ; do
  echo "********************************************************************"
  # 拉取源镜像
  docker pull ${source_image_registry_prefix}${image_name}

  # 重命名镜像
  docker tag ${source_image_registry_prefix}${image_name} ${target_image_registry_prefix}${image_name}

  # 推送镜像
  docker push ${target_image_registry_prefix}${image_name}

  echo "*** [√] ${target_image_registry_prefix}${image_name}"
done

echo "finish ..."