#!/bin/bash

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

# 创建主题(如果不存在)
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --topic $TOPIC_NAME --bootstrap-server kafka-1:9092

# 添加消费者组的读取权限
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka-1:9092  --add  --allow-principal User:ANONYMOUS  --group $GROUP_NAME  --operation Read

# 添加消费者组对主题的读取权限
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka-1:9092 --add  --allow-principal User:ANONYMOUS  --topic $TOPIC_NAME  --operation Read

# 重置消费者组偏移量，实际创建消费者组
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-consumer-groups.sh --bootstrap-server kafka-1:9092  --group $GROUP_NAME   --topic $TOPIC_NAME  --reset-offsets --to-earliest   --execute

echo "消费者组 $GROUP_NAME 已创建并授权成功！"
echo "现在客户端可以使用此消费者组进行消费了。" 