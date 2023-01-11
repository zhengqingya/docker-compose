# Plumelog

一个简单易用的java分布式日志组件

> https://gitee.com/plumeorg/plumelog

```shell
# plumelog + elasticsearch + redis
docker-compose -f docker-compose.yml -p plumelog up -d

# 当前目录下所有文件赋予权限(读、写、执行)  -- 解决es启动报错问题...
chmod -R 777 ./app/elasticsearch
```

- 访问地址：[`ip地址:8891`](http://127.0.0.1:8891)
- 账号：admin
- 密码：admin
