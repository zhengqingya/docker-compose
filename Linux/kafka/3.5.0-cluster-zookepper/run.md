# Kafka -- 未完成版

Kafka是一种基于分布式发布-订阅消息系统的开源软件。 其目标是提供高吞吐量、低延迟、可扩展性和容错能力。
Kafka中将消息存储在可配置数量的分区中，以便实现横向扩展，并且支持多个生产者和消费者，具有良好的可靠性保证机制。
除此之外，Kafka还支持数据复制、故障转移和离线数据处理等功能，并被广泛应用于网站活动跟踪、日志收集与分析、流式处理、消息队列等场景。

### 运行

```shell
# 停止
docker-compose -f docker-compose.yml -p kafka down
# 启动
docker-compose -f docker-compose.yml -p kafka up -d
```

### kafka-map可视化工具

https://github.com/dushixiang/kafka-map

- 访问：http://127.0.0.1:9006
- 账号密码：admin/123456

![img.png](images/kafka-map-01.png)

添加集群 eg: 172.12.6.21:9092,172.12.6.22:9092
![img.png](images/kafka-map-02.png)

![img.png](images/kafka-map-03.png)

### java客户端连接

```yml
spring:
  kafka:
    bootstrap-servers: 127.0.0.1:9093,127.0.0.1:9094 # 指定kafka server地址，集群（多个逗号分隔）
```

### 测试消费

```shell
# 创建主题
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server kafka-1:9092 --topic my-topic --partitions 3 --replication-factor 2
# 控制台生产者
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-console-producer.sh --bootstrap-server kafka-1:9092 --topic my-topic
# 控制台消费者
docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka-1:9092 --topic my-topic


# 手动创建主题
# docker exec -it kafka-1 /opt/bitnami/kafka/bin/kafka-topics.sh --create --topic simple-local --bootstrap-server kafka-1:9092


# 给脚本添加执行权限 -- linux环境
chmod +x create-consumer-group.sh
# 使用脚本创建和授权消费者组 -- 在Windows中可能需要使用Git Bash或WSL运行，脚本执行后，只有被授权的消费者组才能消费指定的主题，未授权的消费者组将被拒绝访问。
# my-consumer-group是您要创建的消费者组名称
# simple-local是主题名称
sh ./create-consumer-group.sh my-consumer-group simple-local
```

![img.png](images/kafka-console-producer-consumer.png)

