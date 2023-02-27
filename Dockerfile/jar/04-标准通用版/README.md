### 使用示例命令

此版本提供出一个`JAVA_OPTS`去设置jar的运行参数

```shell
# 打包镜像 -f:指定Dockerfile文件路径 --no-cache:构建镜像时不使用缓存
docker build -f Dockerfile --build-arg JAVA_OPTS="-XX:+UseG1GC" -t "registry.cn-hangzhou.aliyuncs.com/zhengqing/test:dev" . --no-cache

# 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/test:dev

# 拉取镜像
docker pull registry.cn-hangzhou.aliyuncs.com/zhengqing/test:dev

# 运行
docker run -d -p 8080:666 --name test -e server.port=666 registry.cn-hangzhou.aliyuncs.com/zhengqing/test:dev

# 删除旧容器
docker ps -a | grep test | grep dev | awk '{print $1}' | xargs -i docker stop {} | xargs -I docker rm {}

# 删除旧镜像
docker images | grep -E test | grep dev | awk '{print $3}' | uniq | xargs -I {} docker rmi --force {}
```
