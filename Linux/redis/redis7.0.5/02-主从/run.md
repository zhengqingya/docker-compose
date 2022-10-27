### Redis

```shell
# 当前目录下所有文件赋予权限(读、写、执行)
chmod -R 777 ./redis-master-slave
# 运行 -- 主从复制模式-一主二从（主写从读）
docker-compose -f docker-compose-redis-master-slave.yml -p redis up -d
```

###### 连接redis

```shell
# 密码为123456
docker exec -it redis-master redis-cli -p 6380 -a 123456
```
