### Redis

```shell
# 当前目录下所有文件赋予权限(读、写、执行)
chmod -R 777 ./redis
# 运行 -- 单机模式
docker-compose -f docker-compose-redis.yml -p redis up -d
```

###### 连接redis

```shell
# 密码为123456
docker exec -it redis redis-cli -a 123456
```
