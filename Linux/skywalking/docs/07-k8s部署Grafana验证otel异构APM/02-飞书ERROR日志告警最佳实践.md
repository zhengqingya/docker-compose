# 飞书ERROR日志告警最佳实践

配置效果：
![](./images/02-飞书ERROR日志告警最佳实践-1782666984560.png)

```shell
10s 评估一次
查询最近 1 分钟 ERROR
按服务 + 环境 + 命名空间 + 错误摘要聚合
飞书通知展示错误数、Trace数、环境、接口、Pod、样例TraceId和日志样例
```

配置步骤简述：

1. `Contact point`：配置飞书 Webhook 接收方和消息卡片模板，决定飞书最终收到什么内容、按钮跳转到哪里。
2. `Alert rule`：配置 Loki 查询和触发条件，决定什么样的 ERROR 日志会变成 Grafana 告警。
3. `Notification policy`：配置告警路由、聚合和重复提醒频率，决定哪些告警发到飞书以及多久发一次。
4. `验证`：通过 Java Demo 主动制造 ERROR 日志，确认 Loki、Grafana 告警和飞书推送链路全部打通。


### 一、配置 Contact point

Alerting -> Notification configuration -> Contact points -> New contact point

```text
Name: 测试推送-feishu
Integration: Webhook
URL: 飞书群机器人 Webhook 地址
HTTP Method: POST
Disable resolved message: 开启
```

`Custom Payload` 选择 `Enter custom payload template`，填入：

```gotemplate
{{ coll.Dict
  "msg_type" "interactive"
  "card" (coll.Dict
    "config" (coll.Dict "wide_screen_mode" true)
    "header" (coll.Dict
      "template" "red"
      "title" (coll.Dict "tag" "plain_text" "content" (printf "[%s] %s｜ERROR %s条/1分钟｜%d条Trace"
        (or (index .CommonLabels "severity") (index (index .Alerts.Firing 0).Labels "severity") "P2")
        (or (index .CommonLabels "service_name") (index (index .Alerts.Firing 0).Labels "service_name") "未知服务")
        (reReplaceAll "\\.0+$" "" (printf "%v" (or (index (index .Alerts.Firing 0).Values "B") (index (index .Alerts.Firing 0).Values "A") "已触发")))
        (len .Alerts.Firing)
      ))
    )
    "elements" (coll.Slice
      (coll.Dict
        "tag" "div"
        "text" (coll.Dict
          "tag" "lark_md"
          "content" (printf "最近1分钟检测到 %s 条 ERROR，涉及 %d 条 Trace。\n**主要错误：** %s\n\n**环境：** %s\n**命名空间：** %s\n**服务：** %s\n**接口：** %s %s\n**Pod样例：** %s\n**首次触发：** %s\n**日志范围：** 最近5分钟\n\n**样例TraceId：** %s\n**样例日志：** %s"
            (reReplaceAll "\\.0+$" "" (printf "%v" (or (index (index .Alerts.Firing 0).Values "B") (index (index .Alerts.Firing 0).Values "A") "已触发")))
            (len .Alerts.Firing)
            (or (index (index .Alerts.Firing 0).Labels "error_message") "无")
            (or (index .CommonLabels "deployment_environment") (index .CommonLabels "environment") (index .CommonLabels "env") (index (index .Alerts.Firing 0).Labels "deployment_environment") (index (index .Alerts.Firing 0).Labels "environment") (index (index .Alerts.Firing 0).Labels "env") "未知")
            (or (index .CommonLabels "k8s_namespace_name") (index .CommonLabels "service_namespace") (index .CommonLabels "namespace") (index (index .Alerts.Firing 0).Labels "k8s_namespace_name") (index (index .Alerts.Firing 0).Labels "service_namespace") (index (index .Alerts.Firing 0).Labels "namespace") "未知")
            (or (index .CommonLabels "service_name") (index (index .Alerts.Firing 0).Labels "service_name") "未知服务")
            (or (index (index .Alerts.Firing 0).Labels "http_request_method") (index (index .Alerts.Firing 0).Labels "http_method") "未识别")
            (or (index (index .Alerts.Firing 0).Labels "http_route") (index (index .Alerts.Firing 0).Labels "url_path") (index (index .Alerts.Firing 0).Labels "path") "未识别")
            (or (index (index .Alerts.Firing 0).Labels "k8s_pod_name") (index (index .Alerts.Firing 0).Labels "pod") (index (index .Alerts.Firing 0).Labels "pod_name") "未识别")
            (date "2006-01-02 15:04:05" (tz "Asia/Shanghai" (index .Alerts.Firing 0).StartsAt))
            (or (index (index .Alerts.Firing 0).Labels "trace_id") "无")
            (or (index (index .Alerts.Firing 0).Labels "error_message") "无")
          )
        )
      )
      (coll.Dict
        "tag" "action"
        "actions" (coll.Slice
          (coll.Dict "tag" "button" "type" "primary" "text" (coll.Dict "tag" "plain_text" "content" "查看错误日志") "url" (printf "%s/explore?schemaVersion=1&panes=%%7B%%22errorLogs%%22%%3A%%7B%%22datasource%%22%%3A%%22loki%%22%%2C%%22queries%%22%%3A%%5B%%7B%%22refId%%22%%3A%%22A%%22%%2C%%22datasource%%22%%3A%%7B%%22type%%22%%3A%%22loki%%22%%2C%%22uid%%22%%3A%%22loki%%22%%7D%%2C%%22editorMode%%22%%3A%%22code%%22%%2C%%22expr%%22%%3A%%22%%7Bservice_name%%3D%%5C%%22%s%%5C%%22%%7D%%20%%7C%%20detected_level%%20%%3D%%20%%5C%%22ERROR%%5C%%22%%22%%7D%%5D%%2C%%22range%%22%%3A%%7B%%22from%%22%%3A%%22now-5m%%22%%2C%%22to%%22%%3A%%22now%%22%%7D%%7D%%7D&orgId=1" (reReplaceAll "/$" "" (or .ExternalURL "http://127.0.0.1:30080")) (or (index .CommonLabels "service_name") (index (index .Alerts.Firing 0).Labels "service_name") "未知服务")))
          (coll.Dict "tag" "button" "type" "primary" "text" (coll.Dict "tag" "plain_text" "content" "查看样例链路") "url" (printf "%s/explore?schemaVersion=1&panes=%%7B%%22trace%%22%%3A%%7B%%22datasource%%22%%3A%%22tempo%%22%%2C%%22queries%%22%%3A%%5B%%7B%%22refId%%22%%3A%%22A%%22%%2C%%22datasource%%22%%3A%%7B%%22type%%22%%3A%%22tempo%%22%%2C%%22uid%%22%%3A%%22tempo%%22%%7D%%2C%%22query%%22%%3A%%22%s%%22%%2C%%22queryType%%22%%3A%%22traceql%%22%%7D%%5D%%2C%%22range%%22%%3A%%7B%%22from%%22%%3A%%22now-5m%%22%%2C%%22to%%22%%3A%%22now%%22%%7D%%7D%%7D&orgId=1" (reReplaceAll "/$" "" (or .ExternalURL "http://127.0.0.1:30080")) (or (index (index .Alerts.Firing 0).Labels "trace_id") "无")))
          (coll.Dict "tag" "button" "text" (coll.Dict "tag" "plain_text" "content" "服务Dashboard") "url" (printf "%s/d/otel-service-analysis?orgId=1&var-service=%s&from=now-5m&to=now" (reReplaceAll "/$" "" (or .ExternalURL "http://127.0.0.1:30080")) (or (index .CommonLabels "service_name") (index (index .Alerts.Firing 0).Labels "service_name") "未知服务")))
          (coll.Dict "tag" "button" "text" (coll.Dict "tag" "plain_text" "content" "静默告警") "url" (index .Alerts.Firing 0).SilenceURL)
        )
      )
    )
  )
| data.ToJSON }}
```

Save contact point

![](./images/手动配置飞书ERROR日志告警-1782496803315.png)
![](./images/手动配置飞书ERROR日志告警-1782496850279.png)


### 二、配置 Alert rule

Alerting -> Alert rules -> New alert rule

#### 1. Enter alert rule name

ERROR日志聚合告警

#### 2. Define query and alert condition

查询选择 `Loki`，查询类型选择 `Instant`。

说明：

1. `Loki`：从日志库中查询应用上报的 OTel 日志，本规则基于 ERROR 日志触发告警。
2. `Instant`：每次评估只取当前时刻的查询结果，适合告警规则判断是否立即满足触发条件。

LogQL：返回最近 1 分钟内的 ERROR 日志聚合结果，并保留样例 TraceId、Pod、接口等标签用于飞书展示。

```logql
(
  sum by (service_name, deployment_environment, environment, env, k8s_namespace_name, service_namespace, namespace, trace_id, error_message, k8s_pod_name, pod, pod_name, http_request_method, http_method, http_route, url_path, path) (
    count_over_time({service_name=~"demo-k8s-otel-.*"} | detected_level = "ERROR" | trace_id != "" | regexp `(?P<error_message>.{1,120}).*` [1m])
  ) * 0
)
+ on (service_name, deployment_environment, environment, env, k8s_namespace_name, service_namespace, namespace, error_message) group_left()
(
  sum by (service_name, deployment_environment, environment, env, k8s_namespace_name, service_namespace, namespace, error_message) (
    count_over_time({service_name=~"demo-k8s-otel-.*"} | detected_level = "ERROR" | trace_id != "" | regexp `(?P<error_message>.{1,120}).*` [1m])
  )
)
```

告警条件：`WHEN QUERY IS ABOVE 0`

> 当查询的结果大于 0 时，触发告警。

![](./images/02-飞书ERROR日志告警最佳实践-1782666365781.png)

#### 3. Add folder and labels

1. New folder: OTel告警
2. Labels：
  ```text
  source = loki
  type = error_log
  severity = P2
  ```

![](./images/手动配置飞书ERROR日志告警-1782497692706.png)

作用：

1. `Folder`：用于在 Grafana 中归类管理告警规则，方便后续查找和维护。
2. `Labels`：用于标识告警来源、类型和级别，也可被 Notification policy 用来匹配路由到飞书。

#### 4. Set evaluation behavior

```shell
Evaluation group name: otel-error-log-10s
Evaluation interval: 10s      # 控制 Grafana 多久执行一次 LogQL 查询，间隔越短，发现 ERROR 日志越快。
Pending period: None          # 控制条件满足后是否等待一段时间再触发告警，选择 `None` 表示立即触发。
Keep firing for: None         # 控制条件恢复后告警继续保持 Firing 的时间，选择 `None` 表示恢复后立即回到正常。
No data: Normal               # 控制查不到数据时的告警状态，`Normal` 表示没有 ERROR 日志时保持正常。
Error: Keep Last State        # 控制查询报错或超时时的告警状态，`Keep Last State` 表示保持上一次状态，避免数据源短暂抖动导致误告警。
```

![](./images/手动配置飞书ERROR日志告警-1782498056310.png)

#### 5. Configure notifications

作用：配置当前告警规则触发后直接通知哪个 Contact point。这里选择 `测试推送-feishu`，表示该规则进入 Firing 后会交给飞书 Webhook 发送。

![](./images/手动配置飞书ERROR日志告警-1782498081739.png)

#### 6. Configure notification message

作用：配置告警摘要和描述信息，用于 Grafana 告警详情、通知内容上下文和排查说明。
这里通过 `$labels.service_name`、`$labels.trace_id` 引用 LogQL 聚合出来的服务名和 TraceId。

```text
summary = 服务 {{ $labels.service_name }} 最近1分钟出现 ERROR 日志，主要错误={{ $labels.error_message }}
description = 最近1分钟检测到 ERROR 日志，请进入 Loki 查询日志或通过样例 TraceId 跳转 Tempo 链路。
```

![](./images/手动配置飞书ERROR日志告警-1782498176263.png)

Save

### 三、配置 Notification policy

Alerting -> Notification configuration -> Notification policies

> 作用：配置告警通知路由和聚合策略，决定哪些告警发给哪个 Contact point，以及同一类告警如何合并、多久重复提醒一次。这里用于把 ERROR 日志告警路由到飞书，并控制推送频率，避免短时间内大量错误日志刷屏。

New notification policy：

```text
name: notice-feishu              # 策略名称

Contact point: 测试推送-feishu     # 指定告警最终发送到哪个联络点，这里发送到飞书 Webhook。

Group by:
  grafana_folder              # 按 Grafana 告警目录分组，避免不同目录下的告警规则混在一起。
  alertname                   # 按告警名称分组，确保同类告警规则聚合到同一条通知中。
  deployment_environment      # 按部署环境分组（如 prod / staging / test），区分不同环境的告警。
  environment                 # 兼容不同数据源或团队对环境的字段命名，统一按环境维度聚合。
  env                         # 再次兼容 env 简写字段，防止环境维度缺失导致分组混乱。
  k8s_namespace_name          # 按 Kubernetes Namespace 分组，方便定位具体集群内的资源。
  service_namespace           # 按服务所属命名空间分组，适配非 K8s 场景下的微服务划分。
  namespace                   # 兼容多种平台对 namespace 的命名方式，确保分组稳定。
  service_name                # 按服务名分组，同一服务的异常日志或指标会聚合展示。
  error_message               # 按错误详情分组，相同错误内容合并，不同错误分开推送，便于快速定位问题根因。

Group wait: 5s                # 新告警组出现后等待多久发送第一条通知，时间越短推送越及时。
Group interval: 30s           # 同一告警组已有通知后，组内有新变化时至少间隔多久再发送更新通知。
Repeat interval: 1m           # 告警一直未恢复且没有新变化时，多久重复提醒一次。
```

![](./images/02-飞书ERROR日志告警最佳实践-1782666617234.png)
![](./images/02-飞书ERROR日志告警最佳实践-1782666635716.png)

### 四、验证

触发真实 ERROR 日志：

```shell
curl "http://127.0.0.1:30082/error?random=false"
```

![](./images/02-飞书ERROR日志告警最佳实践-1782666886295.png)

确认 Loki 有数据：

```logql
{service_name=~"demo-k8s-otel-.*"} | detected_level = "ERROR" | trace_id != ""
```

查看飞书消息
![](./images/02-飞书ERROR日志告警最佳实践-1782666967635.png)
