### RabbitMQ

```shell
mkdir -p rabbitmq
# 当前目录下所有文件赋予权限(读、写、执行)
chmod -R 777 ./rabbitmq
# 运行 [ 注：如果之前有安装过，需要清除浏览器缓存和删除rabbitmq相关的存储数据(如:这里映射到宿主机的data数据目录)，再重装，否则会出现一定问题！ ]
# 运行3.7.8-management版本
docker-compose -f docker-compose-rabbitmq-3.7.8-management.yml -p rabbitmq up -d
```

web管理端：[`ip地址:15672`](http://www.zhengqingya.com:15672)
登录账号密码：`admin/admin`

