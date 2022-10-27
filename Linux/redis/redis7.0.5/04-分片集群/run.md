### Redis

```shell
# 当前目录下所有文件赋予权限(读、写、执行)
chmod -R 777 ./redis-cluster
# 运行 -- Redis Cluster 集群
docker-compose -f docker-compose-redis-cluster.yml -p redis up -d
```

###### 连接redis

```shell
# 密码为123456
docker exec -it redis redis-cli -a 123456
```

###### Redis Cluster 集群

redis.conf中主要新增了如下配置

```
cluster-enabled yes
cluster-config-file nodes-6379.conf
cluster-node-timeout 15000
```

创建集群

```shell
docker exec -it redis-6381 redis-cli -h 172.22.0.11 -p 6381 -a 123456 --cluster create 172.22.0.11:6381 redis-6382:6382 redis-6383:6383 redis-6384:6384 redis-6385:6385 redis-6386:6386 --cluster-replicas 1
```

查看集群

```shell
# 连接集群某个节点
docker exec -it redis-6381 redis-cli -c -h redis-6381 -p 6381 -a 123456
# 查看集群信息
cluster info
# 查看集群节点信息
cluster nodes
# 查看slots分片
cluster slots
```
