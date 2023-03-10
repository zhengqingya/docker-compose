# EFK

`Elasticsearch` + `Filebeat` + `Kibana` 搭建日志监控系统

1. `Filebeat` 采集日志，相比Logstash更加轻量级和易部署，对系统资源开销更小，如果对于日志不需要进行过滤分析的，可以直接使用filebeat
2. `Elasticsearch` 日志搜索
3. `Kibana` 日志展示

```shell
# 运行
docker-compose -f docker-compose.yml -p efk up -d
# 当前目录下所有文件赋予权限(读、写、执行)  -- 解决es启动报错问题...
#chmod -R 777 ./app/elasticsearch
```

1. ES访问地址：[`ip地址:9200`](http://127.0.0.1:9200)
   默认账号密码：`elastic/123456`
2. kibana访问地址：[`ip地址:5601`](http://127.0.0.1:5601)
   默认账号密码：`elastic/123456`
