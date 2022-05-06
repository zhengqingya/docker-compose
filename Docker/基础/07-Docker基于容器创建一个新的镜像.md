# Docker基于容器创建一个新的镜像

```shell
# -a :提交的镜像作者；
# -c :使用Dockerfile指令来创建镜像；
# -m :提交时的说明文字；
# -p :在commit时，将容器暂停。

# 基于容器创建一个新的镜像
docker commit -m "This is MySQL Database 5.7 image" -a "zhengqingya" 容器名 新的镜像
# 推送
docker push 新的镜像
```

---

### ex: 提交一个centos6.6

```shell
# 拉取镜像
docker pull centos:6.6
# 查看镜像
docker images

# 以交互模式运行进入
docker run -i -t --name=centos centos:6.6 bash
ls
mkdir -p /zhengqingya/soft
cd zhengqingya
echo '测试' > test.txt
exit

# 查看操作
docker ps -a

# 检查容器里文件结构的更改
docker diff centos容器ID/容器名

# 提交镜像
docker commit -m "测试提交" -a "zhengqingya" centos容器ID/容器名 registry.cn-hangzhou.aliyuncs.com/zhengqing/centos:latest
# 查看新创建的镜像
docker images 新的镜像名

# 推送到远程仓库
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/centos:latest

# pull自己制作的镜像
docker pull registry.cn-hangzhou.aliyuncs.com/zhengqing/centos:latest

# 运行
docker run -i -t --name=mycentos registry.cn-hangzhou.aliyuncs.com/zhengqing/centos:latest bash
```

### ex: 提交redis

```shell
# 运行进入
docker run --name redis_server -p 6379:6379 -d redis:latest redis-server
ls
mkdir -p /zhengqingya/soft
cd zhengqingya
echo '测试' > test.txt
exit

# 查看操作
docker ps -a
docker diff centos镜像id

# 提交镜像
docker commit -m "测试提交" -a "zhengqingya" centos镜像id registry.cn-hangzhou.aliyuncs.com/zhengqing/redis_test:latest
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/redis_test:latest

# pull自己制作的镜像并运行
docker run --name redis_test_server -p 6000:6379 -d registry.cn-hangzhou.aliyuncs.com/zhengqing/redis_test:latest redis-server
```

### ex: 提交jenkins

```shell
# 检查容器里文件结构的更改
docker diff jenkins

# 提交镜像
docker commit -m "测试提交jenkins" -a "zhengqingya" jenkins registry.cn-hangzhou.aliyuncs.com/zhengqing/jenkins:v1
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/jenkins:v1

# 运行测试
docker run -d --name jenkins_test -p 10000:8080 -u root registry.cn-hangzhou.aliyuncs.com/zhengqing/jenkins:v1
```
