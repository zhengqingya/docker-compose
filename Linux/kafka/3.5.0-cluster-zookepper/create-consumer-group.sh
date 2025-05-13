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

# 创建临时JAAS配置文件
docker exec -i kafka-1 bash -c "cat > /tmp/admin_jaas.conf << EOF
KafkaClient {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username=\"admin\"
  password=\"admin-secret\";
};
EOF"

# 内部连接使用PLAINTEXT协议，指定admin用户身份
# 1、创建主题(如果不存在)
docker exec -i kafka-1 bash -c "
/opt/bitnami/kafka/bin/kafka-topics.sh \
    --bootstrap-server kafka-1:9092 \
    --command-config <(echo 'sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"admin\" password=\"admin-secret\";') \
    --create --if-not-exists \
    --topic $TOPIC_NAME \
    --partitions 3 \
    --replication-factor 2"

# 2、为消费者组添加ACL权限（手动配置消费者组权限）
docker exec -i kafka-1 bash -c "
/opt/bitnami/kafka/bin/kafka-acls.sh \
    --bootstrap-server kafka-1:9092 \
    --command-config <(echo 'sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"admin\" password=\"admin-secret\";') \
    --add --allow-principal User:admin \
    --operation Read --operation Describe \
    --group $GROUP_NAME"

# 3、为主题添加生产和消费的ACL权限
docker exec -i kafka-1 bash -c "
/opt/bitnami/kafka/bin/kafka-acls.sh \
    --bootstrap-server kafka-1:9092 \
    --command-config <(echo 'sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"admin\" password=\"admin-secret\";') \
    --add --allow-principal User:admin \
    --operation Write --operation Describe --operation Read \
    --topic $TOPIC_NAME"

# 4、为集群通信添加权限（为防止集群间通信问题）
docker exec -i kafka-1 bash -c "
/opt/bitnami/kafka/bin/kafka-acls.sh \
    --bootstrap-server kafka-1:9092 \
    --command-config <(echo 'sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"admin\" password=\"admin-secret\";') \
    --add --allow-principal User:admin \
    --operation All \
    --cluster"

echo "消费者组 $GROUP_NAME 已创建并授权成功！"
echo "现在客户端可以使用此消费者组进行消费了。"
