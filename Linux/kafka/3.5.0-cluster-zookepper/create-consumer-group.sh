#!/bin/bash

####################################
# @description 使用脚本创建和授权消费者组
# @params $1 => 消费者组名称
# @params $2 => 主题名称
# @example => sh create-consumer-group.sh my-consumer-group simple-local
# @author zhengqingya
# @date 2025/05/13 00:28
####################################

# 在执行过程中若遇到使用了未定义的变量或命令返回值为非零，将直接报错退出
set -eu

# 检查参数数量
if [ "$#" -ne 2 ]; then
    echo "用法: $0 <消费者组名称> <主题名称>"
    exit 1
fi

GROUP_NAME=$1
TOPIC_NAME=$2

echo "正在为消费者组 $GROUP_NAME 在主题 $TOPIC_NAME 上设置权限..."


# 1、创建主题(如果不存在)
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server kafka-1:9092 --create --if-not-exists --topic $TOPIC_NAME --partitions 3 --replication-factor 2

# 2、为消费者组添加ACL权限（手动配置消费者组权限）
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka-1:9092 --add --allow-principal User:ANONYMOUS --operation Read --operation Describe --group $GROUP_NAME

# 3、为主题添加生产和消费的ACL权限
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka-1:9092 --add --allow-principal User:ANONYMOUS --operation Write --operation Describe --operation Read --topic $TOPIC_NAME


echo "消费者组 $GROUP_NAME 已创建并授权成功！"
echo "现在客户端可以使用此消费者组进行消费了。"
