#!/bin/bash

####################################
# @description 创建Kafka用户和配置SCRAM凭证
# @params $1 => 用户名
# @params $2 => 密码
# @example => sh create-users.sh test-user test-password
# @author zhengqingya
# @date 2025/05/13 00:28
####################################

# 在执行过程中若遇到使用了未定义的变量或命令返回值为非零，将直接报错退出
set -eu

# 检查参数数量
if [ "$#" -ne 2 ]; then
    echo "用法: $0 <用户名> <密码>"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

echo "正在创建用户 $USERNAME..."

# 创建临时配置文件，指定admin用户身份
docker exec -i kafka-1 bash -c "cat > /tmp/admin_command.properties << EOF
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"admin\" password=\"admin-secret\";
EOF

# 为admin添加超级用户权限（如果未添加）
/opt/bitnami/kafka/bin/kafka-acls.sh \
    --bootstrap-server kafka-1:9092 \
    --command-config /tmp/admin_command.properties \
    --add \
    --allow-principal User:admin \
    --operation All \
    --cluster

# 创建SCRAM凭证
/opt/bitnami/kafka/bin/kafka-configs.sh \
    --bootstrap-server kafka-1:9092 \
    --command-config /tmp/admin_command.properties \
    --alter \
    --add-config \"SCRAM-SHA-256=[password=$PASSWORD]\" \
    --entity-type users \
    --entity-name $USERNAME"

# 为新创建的用户添加必要的权限
docker exec -i kafka-1 bash -c "
# 允许用户读写消息
/opt/bitnami/kafka/bin/kafka-acls.sh \
    --bootstrap-server kafka-1:9092 \
    --command-config /tmp/admin_command.properties \
    --add \
    --allow-principal User:$USERNAME \
    --operation Read --operation Write \
    --topic '*'

# 允许用户加入消费者组
/opt/bitnami/kafka/bin/kafka-acls.sh \
    --bootstrap-server kafka-1:9092 \
    --command-config /tmp/admin_command.properties \
    --add \
    --allow-principal User:$USERNAME \
    --operation Read \
    --group '*'"

echo "用户 $USERNAME 创建成功！"
echo "可以使用以下JAAS配置连接Kafka:"
echo "------------------------------"
echo "sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username=\"$USERNAME\" password=\"$PASSWORD\";"
echo "security.protocol=SASL_PLAINTEXT"
echo "sasl.mechanism=SCRAM-SHA-256"
echo "------------------------------"
