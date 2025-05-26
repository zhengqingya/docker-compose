# Kafka 单机 & SASL & SSL -- 未完成版本...

### 一、运行

```shell
docker-compose -f docker-compose.yml up -d
```

### 二、ACL授权

```shell
# 配置ACL授权 -- 不配置的情况下，java客户端会提示：org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: xxx
docker exec -it kafka /opt/bitnami/kafka/bin/kafka-acls.sh --bootstrap-server kafka:9092 --command-config /opt/bitnami/kafka/config/admin.properties --add --allow-principal User:test --operation ALL --topic '*' --group 'test-group'
```

### 三、图形化工具访问

访问地址：http://localhost:7766

集群地址：host.docker.internal:9092

集群管理属性配置

```
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="admin" password="123456";
```

![](images/run_1748279177146.png)
![](images/run_1748279225447.png)

### 四、SpringBoot连接配置

```yaml
spring:
  kafka:
    bootstrap-servers: 127.0.0.1:9092
    properties:
      security.protocol: SASL_PLAINTEXT
      sasl.mechanism: PLAIN
      sasl.jaas.config: 'org.apache.kafka.common.security.scram.ScramLoginModule required username="admin" password="123456";'
```

