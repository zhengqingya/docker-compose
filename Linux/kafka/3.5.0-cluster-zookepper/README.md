# Kafka 集群部署 (SASL_PLAINTEXT + SCRAM-SHA-256) -- 未完成版本...

这是一个使用 Docker Compose 部署的 Kafka 集群，具有以下特性：

- 使用 SASL_PLAINTEXT 进行通信认证（外部连接）
- 使用 SCRAM-SHA-256 用户认证机制
- 基于 ACL 的访问控制
- 包含 Kafka-Map 图形化管理界面

## 快速开始

### 1. 启动集群

```bash
# 给脚本执行权限
chmod +x *.sh

# 启动集群并初始化
sh ./setup-kafka.sh
```

初始化过程会：

- 启动 Kafka 和 Zookeeper 容器
- 创建 admin 用户的 SCRAM 凭证
- 创建示例主题和消费者组

### 2. 创建用户

```bash
# 创建新用户
sh ./create-users.sh test-user test-password
```

### 3. 创建主题和消费者组

```bash
# 创建主题和授权
sh ./create-consumer-group.sh my-group my-topic
```

## 管理界面

Kafka-Map 图形化管理界面：

- 地址: http://localhost:9006
- 用户名: admin
- 密码: 123456

添加集群时，使用以下配置：

1. 基本配置：

  - 集群名称：自定义，例如 `kafka-cluster-sasl`
  - Bootstrap Servers：`kafka-1:9092,kafka-2:9092`

2. SASL 配置（必须选择）：
  - 安全协议: SASL_PLAINTEXT
  - SASL 机制: SCRAM-SHA-256
  - SASL 用户名: admin
  - SASL 密码: admin-secret

系统已经通过挂载 `/kafka_client.properties` 到 Kafka-Map 容器中自动配置了 SASL 认证，因此能够正确连接到启用了 SASL 认证的 Kafka 集群。

## 目录结构

```
├── config/
│   ├── kafka_jaas.conf      # Kafka JAAS配置
│   ├── zookeeper_jaas.conf  # Zookeeper JAAS配置
│   ├── producer.properties  # 生产者配置
│   ├── consumer.properties  # 消费者配置
│   ├── kafka_client.properties # Kafka-Map连接配置
├── create-consumer-group.sh # 创建消费者组脚本
├── create-users.sh          # 创建用户脚本
├── setup-kafka.sh           # 初始化脚本
├── docker-compose.yml       # Docker Compose配置
└── README.md                # 说明文档
```

## 配置说明

### 重要环境变量

- `ALLOW_PLAINTEXT_LISTENER`: 设置为 `yes` 允许使用明文监听器。尽管我们使用 SASL 认证，但在开发环境中仍需要此设置来避免启动错误。
- `KAFKA_ZOOKEEPER_PROTOCOL`: 设置为 `SASL` 以使用 SASL 认证连接 Zookeeper。
- `KAFKA_ZOOKEEPER_USER`: Zookeeper 的 SASL 认证用户名，需要与 Zookeeper 配置中的 `ZOO_SERVER_USERS` 对应。
- `KAFKA_ZOOKEEPER_PASSWORD`: Zookeeper 的 SASL 认证密码，需要与 `ZOO_SERVER_PASSWORDS` 对应。
- `KAFKA_CFG_LISTENER_NAME_EXTERNAL_SASL_ENABLED_MECHANISMS`: 设置外部监听器启用的 SASL 机制为 `SCRAM-SHA-256`。
- `KAFKA_CFG_LISTENER_NAME_INTERNAL_SASL_ENABLED_MECHANISMS`: 设置为空，在内部监听器上禁用所有 SASL 机制。
- `KAFKA_CFG_SUPER_USERS`: 设置超级用户列表，包含 `User:admin` 和 `User:ANONYMOUS`，确保内部 PLAINTEXT 连接也具有必要权限。

### 认证体系

- **Zookeeper 认证**: 使用 SASL/DIGEST-MD5 机制，在 `zookeeper_jaas.conf` 中配置。
- **Kafka 集群内部通信**:
  - 使用 PLAINTEXT 协议，完全禁用 SASL 机制，简化集群内部通信。
  - 内部通信默认使用 ANONYMOUS 用户，该用户通过超级用户配置获得集群权限。
  - 也可以通过脚本中使用 `--command-config` 参数指定认证信息，实现以特定用户身份执行命令。
- **Kafka 外部访问认证**: 使用 SASL_PLAINTEXT 协议，认证机制为 SCRAM-SHA-256，保证客户端连接安全。
- **Kafka-Map 认证**: 通过挂载配置文件，使用 SASL_PLAINTEXT 协议和 SCRAM-SHA-256 认证机制。

### 命令行工具的身份认证

在脚本中，我们使用以下方式指定 Kafka 命令的认证信息：

1. 创建命令配置文件方式：

   ```bash
   # 创建配置文件
   cat > /tmp/admin_command.properties << EOF
   sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin-secret";
   EOF

   # 使用配置文件执行命令
   kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/admin_command.properties ...
   ```

2. 内联命令方式：
   ```bash
   kafka-acls.sh --bootstrap-server localhost:9092 \
       --command-config <(echo 'sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin-secret";') \
       ...
   ```

这两种方式都可以在不修改 JAAS 配置文件的情况下，为特定命令指定身份信息。

### 监听器配置

本配置使用两种不同的监听器，每个具有不同的安全设置：

1. **INTERNAL 监听器** (端口 9092)

  - 协议: PLAINTEXT
  - 认证: 无 (使用 ANONYMOUS 用户)
  - 用途: 仅供 Kafka 节点之间内部通信使用
  - SASL 机制: 无 (通过 `KAFKA_CFG_LISTENER_NAME_INTERNAL_SASL_ENABLED_MECHANISMS: ""` 禁用)

2. **EXTERNAL 监听器** (端口 9093/9094)
  - 协议: SASL_PLAINTEXT
  - 认证: SCRAM-SHA-256
  - 用途: 供外部客户端连接使用
  - SASL 机制: SCRAM-SHA-256 (通过 `KAFKA_CFG_LISTENER_NAME_EXTERNAL_SASL_ENABLED_MECHANISMS: SCRAM-SHA-256` 启用)

## 注意事项

1. 该集群配置在外部连接时使用 SASL_PLAINTEXT，它提供了身份验证但**没有加密**数据传输。在生产环境中，建议使用 SASL_SSL 以提供加密保护。

2. 为了简化配置和避免内部通信问题，集群内部通信（broker 间）使用明文 PLAINTEXT 协议，并且通过特定监听器配置明确禁用了 SASL 机制。在真正的生产环境中，应当考虑对内部通信也使用 SASL 认证。

3. 配置了 ANONYMOUS 用户作为超级用户，以便在内部 PLAINTEXT 连接中有足够的权限执行集群操作。在生产环境中，应当使用更严格的安全措施。

4. 在脚本中，可以通过 `--command-config` 参数指定身份信息，而不是依赖 ANONYMOUS 用户权限，这提供了更好的安全性和可追踪性。

5. 默认配置了 admin 超级用户，可以访问所有资源。在生产环境中，应该谨慎管理超级用户权限。

6. ACL 权限需要手动配置，可以使用`kafka-acls.sh`工具设置。
