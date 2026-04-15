# 运行说明

## 启动

```bash
# 启动
docker compose up -d

# 停止并删除容器、网络
docker compose down
```

## 访问

- SkyWalking UI: http://127.0.0.1:18080
- Zipkin Trace UI: http://127.0.0.1:18080/zipkin
- OAP HealthCheck: http://127.0.0.1:12800/healthcheck
- OTel Collector gRPC: 127.0.0.1:4317
- OTel Collector HTTP: 127.0.0.1:4318
- OAP gRPC: 127.0.0.1:11800

## 推荐链路

```text
App -> OTel Collector(4317/4318) -> SkyWalking OAP(11800/12800) -> BanyanDB -> SkyWalking UI
```

## Java 标准接入

JVM 参数：

```shell
-javaagent:/data/opentelemetry-javaagent.jar
-Dotel.service.name=demo-skywalking-otel
-Dotel.resource.attributes=deployment.environment=dev,service.namespace=default
-Dotel.traces.exporter=otlp
-Dotel.metrics.exporter=otlp
-Dotel.logs.exporter=otlp
-Dotel.exporter.otlp.protocol=grpc
-Dotel.exporter.otlp.endpoint=http://127.0.0.1:4317
```

## 验证

1. 启动服务后，先确认 `http://127.0.0.1:12800/healthcheck` 返回 `200 OK`
2. 启动应用并访问几次业务接口，例如 `http://127.0.0.1/time`
3. 打开 `http://127.0.0.1:18080/zipkin`，确认能按服务名查看 OTel traces
4. 打开 SkyWalking UI，确认服务、JVM / Runtime 指标与应用日志都能按服务维度查看
5. 不要用 `General-Service -> Trace` 作为 OTel traces 的验证入口，这个页面对应的是 SkyWalking 原生 trace 模型

## 说明

- 第一版 metrics rules 先启用 `vm`，目的是优先让 JVM / Runtime 指标在 SkyWalking 中可读可展示。
- 如果后续要展示业务自定义 metrics，通常还需要继续补充 OAP 侧 otel-rules，而不是只改 Collector。
- 这套目录当前采用的是 `OTel Agent/SDK -> OTel Collector -> SkyWalking OAP` 标准 OTLP 方案。
- 在 SkyWalking 中，OTel traces 会转换为 Zipkin trace 模型，因此正确查看入口是 UI 的 `/zipkin` 或 Zipkin Trace 相关菜单，而不是 `General-Service -> Trace` 原生页。
- SkyWalking 原生 UI 中的 `General-Service -> Trace` 更适合 SkyWalking 原生 agent / trace 模型；如果你的目标是直接在原生 Trace 页查看链路，应改用 SkyWalking 原生 agent 探针方式接入。
- 日志与指标仍然通过 SkyWalking 自身的 Log / Metrics 页面查看，不受 Zipkin Trace UI 入口影响。
