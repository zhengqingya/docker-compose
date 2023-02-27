# 制作jdk8的新镜像

解决时区问题&支持字体

> 注：jre中并没有携带工具文件，ex: arthas 需要依赖lib包和bin包里面的包和工具...

```shell
# 构建镜像 注：有点慢
docker build -t registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine . --no-cache
# 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine

# Dockerfile中引用新镜像
# FROM registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine
```
