# Kafka 单机 & SASL 认证版 -- 待验证

> 部署参考： https://juejin.cn/post/7294556533932884020#heading-3

## 一、运行

```shell
docker-compose -f docker-compose.yml up -d
```

## 二、测试消息收发


```shell
# 发送消息
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-console-producer.sh --bootstrap-server kafka-1:9092 --topic test-topic
# 接收消息
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka-1:9092 --topic test-topic --group test-group


# 1、创建主题(如果不存在)
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server kafka-1:9092 --create --if-not-exists --topic topic1 --partitions 3 --replication-factor 2

# 2、为消费者组添加ACL权限（手动配置消费者组权限） -- 有了消费者组权限之后就可以订阅主题消息了...
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka-1:9092 --add --allow-principal User:test --operation Read --operation Describe --group group1

# 3、为主题添加生产和消费的ACL权限
# docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka-1:9092 --add --allow-principal User:test --operation Write --operation Describe --operation Read --topic topic1

# 4、为集群内部通信添加权限（必须步骤，否则集群节点间通信会被拒绝）
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka-1:9092 --add --allow-principal User:ANONYMOUS --operation All --cluster

# 5、查看设置的ACL权限
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka-1:9092 --list

# 6、控制台生产者 -- 测试生产消息
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-console-producer.sh --bootstrap-server 192.168.176.1:9092 --topic topic1 --producer.config /opt/bitnami/kafka/config/producer.properties

# 7、控制台消费者 -- 使用指定的消费者组消费消息
# docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka-1:9092 --topic topic1 --group group1 --from-beginning
# 测试不同账号的授权
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server 192.168.176.1:9092 --topic topic1 --group group1 --consumer.config /opt/bitnami/kafka/config/consumer-admin.properties
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server 192.168.176.1:9092 --topic topic1 --group group1 --consumer.config /opt/bitnami/kafka/config/consumer-test.properties


```

## 三、图形化工具访问

访问地址：http://localhost:7766

集群地址：host.docker.internal:9092

集群管理属性配置

```
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin-secret";
```