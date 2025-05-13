#!/bin/bash

####################################
# @description 初始化Kafka集群并创建初始用户
# @author zhengqingya
# @date 2025/05/13 00:28
####################################

# 在执行过程中若遇到使用了未定义的变量或命令返回值为非零，将直接报错退出
set -eu

echo "开始启动Kafka集群..."

# 确保清理所有容器
docker-compose down -v

# 启动Kafka集群
docker-compose up -d

# 等待Kafka启动完成
echo "等待Kafka集群启动完成..."
sleep 30

# 创建内部通信用的broker用户证书，使用PLAINTEXT直接连接
echo "创建Kafka内部通信凭证..."
docker exec -i kafka-1 bash -c '
# 创建命令配置文件，指定admin身份
cat > /tmp/admin_command.properties << EOF
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin-secret";
EOF

# 创建admin用户的SCRAM凭证
/opt/bitnami/kafka/bin/kafka-configs.sh \
    --bootstrap-server localhost:9092 \
    --alter \
    --add-config "SCRAM-SHA-256=[password=admin-secret]" \
    --entity-type users \
    --entity-name admin

# 确保admin用户有超级用户权限
/opt/bitnami/kafka/bin/kafka-acls.sh \
    --bootstrap-server localhost:9092 \
    --command-config /tmp/admin_command.properties \
    --add \
    --allow-principal User:admin \
    --operation All \
    --cluster
'

# 等待权限生效
sleep 5

# 创建示例主题和消费者组
echo "创建示例主题和消费者组..."
sh ./create-consumer-group.sh test-consumer-group test-topic

echo "Kafka集群已成功设置完成！"
echo ""
echo "现在您可以使用以下脚本创建新用户："
echo "  sh ./create-users.sh <用户名> <密码>"
echo ""
echo "可以使用Kafka-Map访问集群管理界面："
echo "  http://localhost:9006"
echo "  用户名: admin"
echo "  密码: 123456"
echo ""
echo "添加集群时，请使用以下SASL配置："
echo "  安全协议: SASL_PLAINTEXT"
echo "  SASL机制: SCRAM-SHA-256"
echo "  SASL用户名: admin"
echo "  SASL密码: admin-secret"
