### Docker 安装 Redis

```shell
# 拉取镜像
# docker pull redis
docker pull registry.cn-hangzhou.aliyuncs.com/zhengqing/redis5.0.7

# 启动镜像 -> 运行Redis
docker run -d -p 6379:6379 --name redis_server --restart=always redis
docker run -d -p 6379:6379 --name redis_server --restart=always registry.cn-hangzhou.aliyuncs.com/zhengqing/redis5.0.7

# 查看、连接redis容器
docker exec -ti redis_server redis-cli
```
