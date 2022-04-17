### docker拉取java jdk环境

```shell
docker pull java:latest
```

### 运行项目

```shell
# 1、原生jar运行方式
java -jar xx.jar --spring.profiles.active=prod

# 2、java镜像环境运行方式
docker run -d -p 3001:3001 --restart=always -v /zhengqingya/code/demo/app.jar:/tmp/app.jar --name springboot java:latest java -jar /tmp/app.jar

# 3、可远程调试运行方式
docker run -d -p 5000:5000 -p 50001:50001 --name demo \
-v /zhengqingya/code/demo/app.jar:/tmp/app.jar \
java:latest \
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=50001 -jar /tmp/app.jar --spring.profiles.active=prod

# 4、从镜像仓库拉取运行方式
docker run -d -p 5000:5000 -p 50001:50001 \
-e PROFILE=prod \
--restart always \
--name demo \
registry.cn-hangzhou.aliyuncs.com/zhengqing/demo
```

### 其它

```shell
# arthas 相关
docker exec -it demo /bin/sh -c "wget https://alibaba.github.io/arthas/arthas-boot.jar && java -jar arthas-boot.jar"

docker exec -it demo /bin/sh -c "java -jar /opt/arthas/arthas-boot.jar"
```
