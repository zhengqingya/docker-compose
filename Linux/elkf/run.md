# ELKF

`Elasticsearch` + `Logstash` + `Kibana` + `Filebeat` 搭建日志监控系统

1. `Filebeat` 采集日志
2. `Logstash` 日志过滤
3. `Elasticsearch` 日志搜索
4. `Kibana` 日志展示

> tips: 目前版本存在filebeat收集日志到logstash时乱码问题；
> 如果直接在springboot中推日志到logstash中则正常。

```shell
# 运行
docker-compose -f docker-compose.yml -p elkf up -d
# 当前目录下所有文件赋予权限(读、写、执行)  -- 解决es启动报错问题...
chmod -R 777 ./app/elasticsearch
# 解决logstash启动报错问题...
chmod -R 777 ./app/logstash
```

1. ES访问地址：[`ip地址:9200`](http://127.0.0.1:9200)
   默认账号密码：`elastic/123456`
2. kibana访问地址：[`ip地址:5601`](http://127.0.0.1:5601)
   默认账号密码：`elastic/123456`

---

### Kibana配置日志查看

> tips: 在`./app/filebeat/my-log/demo.log`中添加日志数据

#### 1、创建索引模式

http://127.0.0.1:5601/app/management/kibana/indexPatterns

![img.png](images/log-01.png)
![img.png](images/log-02.png)
![img.png](images/log-03.png)
![img.png](images/log-04.png)

#### 2、查看日志

> [http://127.0.0.1:5601/app/discover](http://127.0.0.1:5601/app/discover)

![img.png](images/log-05.png)
![img.png](images/log-06.png)


