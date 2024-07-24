# Elasticsearch

### 部署

```shell
# 运行
docker-compose -f docker-compose-elasticsearch.yml -p elasticsearch up -d
# 运行后，给当前目录下所有文件赋予权限(读、写、执行)
#chmod -R 777 ./elasticsearch
```

1. ES访问地址：[`ip地址:9200`](http://www.zhengqingya.com:9200)
   默认账号密码：`elastic/123456`
2. kibana访问地址：[`ip地址:5601/app/dev_tools#/console`](http://www.zhengqingya.com:5601/app/dev_tools#/console)
   默认账号密码：`elastic/123456`
