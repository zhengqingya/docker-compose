# EKF

`Elasticsearch` + `Kibana` + `Filebeat` 搭建日志监控系统

1. `Filebeat` 采集日志
2. `Elasticsearch` 日志搜索
3. `Kibana` 日志展示

```shell
# 运行
docker-compose -f docker-compose.yml -p ekf up -d
# 当前目录下所有文件赋予权限(读、写、执行)  -- 解决es启动报错问题...
chmod -R 777 ./app/elasticsearch
```

1. ES访问地址：[`ip地址:9200`](http://127.0.0.1:9200)
   默认账号密码：`elastic/123456`
2. kibana访问地址：[`ip地址:5601`](http://127.0.0.1:5601)
   默认账号密码：`elastic/123456`
