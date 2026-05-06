### Prometheus + Grafana 监控 Java 服务

| 组件 | 作用 | 是否必须 |
| --- | --- | --- |
| Prometheus | 指标采集与时序数据存储，定时拉取 Java 服务等 `/metrics` 指标。 | 必须 |
| Grafana | 指标可视化、Dashboard 展示和告警配置，数据源使用 Prometheus。 | 推荐必须 |
| Java Actuator/Micrometer | Java 应用内置指标暴露能力，提供 `/actuator/prometheus` 给 Prometheus 采集。 | 监控 Java 服务时需要 |

整体链路：

```text
Java服务 /actuator/prometheus  ─┐
Prometheus自身 :9090/metrics    ├─> Prometheus ──> Grafana
                                ┘
```

#### 1. 启停监控组件

```shell
# 启动监控组件
docker compose up -d

# 停止并删除容器、网络
docker compose down
```

#### 2. 访问地址

- Grafana: http://localhost:3000
  - 默认账号: `admin`
  - 默认密码: `admin`
- Prometheus: http://localhost:9090

#### 3. Java 服务接入方式

见 https://gitee.com/zhengqingya/java-workspace

#### 4. Grafana Dashboard

Grafana 已自动配置 Prometheus 数据源。

可在 Grafana 导入这些 Dashboard ID：

- JVM Micrometer: `21064`
- Spring Boot 2.1 Statistics: `21985`

#### 5. 查看采集状态

打开 Prometheus Targets 页面：

```text
http://localhost:9090/targets
```

确认 `prometheus`、`java-app` 都是 `UP`。
