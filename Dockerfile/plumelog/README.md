### 使用示例命令

1. 拉取 https://gitee.com/plumeorg/plumelog 代码
2. 打包 plumelog-server   ( tips: 打包时需要注释`application.properties`配置文件内容，这样外部配置文件才会生效... )
3. 执行以下命令制作镜像

```shell
# 打包镜像 -f:指定Dockerfile文件路径 --no-cache:构建镜像时不使用缓存
docker build -f Dockerfile --build-arg JAVA_OPTS="-XX:+UseG1GC" -t "registry.cn-hangzhou.aliyuncs.com/zhengqing/plumelog:3.5.3" . --no-cache

# 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/plumelog:3.5.3

# 拉取镜像
docker pull registry.cn-hangzhou.aliyuncs.com/zhengqing/plumelog:3.5.3

# 运行
docker run -d -p 8891:8891 --name plumelog -e JAVA_OPTS="-Dserver.port=8891" registry.cn-hangzhou.aliyuncs.com/zhengqing/plumelog:3.5.3

# 删除旧容器
docker ps -a | grep plumelog | grep 3.5.3 | awk '{print $1}' | xargs -I docker stop {} | xargs -I docker rm {}

# 删除旧镜像
docker images | grep -E plumelog | grep 3.5.3 | awk '{print $3}' | uniq | xargs -I {} docker rmi --force {}
```
