# 常用命令

```shell
# 查看当前docker版本
docker -v
docker verison

# 查看docker系统信息
docker info


# 搜索镜像
docker search 镜像
# 获取镜像
docker pull 镜像仓库地址
# 上传镜像
docker push 镜像仓库地址


# 查看镜像的创建历史
docker history 镜像仓库地址

# 运行容器
# –name 定义一个容器的名字，如果在执行docker run时没有指定Name，那么deamon会自动生成一个随机数字符串当做UUID。
# -d 标识是让 docker 容器在后台运行。
# -p 标识通知 Docker 将容器内部使用的网络端口映射到我们使用的主机上。
docker run --name nginx -d -p 8080:80 nginx

# 查询容器内部ip地址
docker inspect 容器ID/容器名 | grep IPAddress

# 列出容器 -- 仅运行的容器
docker ps 
# 列出容器 -- 包含停止的容器
docker ps -a

# 查看当前本地所有镜像
docker images


# 停止容器 
docker stop 容器ID/容器名
# 启动容器
docker start 容器ID/容器名
# 重启容器
docker restart 容器ID/容器名

# 杀掉一个运行中的容器
docker kill -s KILL 容器ID/容器名


# 删除容器
docker rm 容器ID/容器名
# 删除一个或多少容器。-f :通过SIGKILL信号强制删除一个运行中的容器-l :移除容器间的网络连接，而非容器本身-v :-v 删除与容器关联的卷
docker rm -f xx、xx2

# 删除镜像 【 顺序：停止镜像里的容器，再删除容器，最后再删除镜像 】
docker rmi 镜像id/镜像名


# 列出所有的容器 ID
docker ps -aq
# 停止所有的容器
docker stop $(docker ps -aq)
# 删除所有的容器
docker rm $(docker ps -aq)
# 删除所有的镜像
docker rmi $(docker images -q)

# 停止并删除指定容器
docker ps -a | grep 容器ID/容器名 | awk '{print $1}' | xargs -i docker stop {} | xargs -i docker rm {}

# 删除镜像
# docker images 获取所有images
# grep -E "xxxxx" 筛选到特定的images
# awk ‘ {print $3}’ 打印第三列 即image id列
# uniq 检查及删除文本文件中重复出现的行列
# xargs -I {} 多行转单行
# docker rmi --force {} 删除所有指定镜像id
docker images | grep -E "镜像id/镜像名" | awk '{print $3}' | uniq | xargs -I {} docker rmi --force {}
# ex: 删除镜像 `nginx:latest`
docker images | grep -E nginx | grep latest| awk '{print $3}' | uniq | xargs -I {} docker rmi --force {}


# 删除所有停止的容器
docker container prune

# 删除所有不使用的镜像
docker image prune --force --all
# 或
docker image prune -f -a


# 限制容器内存 -m
docker run --name nginx -d -p 8080:80 -m 100m nginx

# 查看容器运行内存信息  【参数`mem_limit: 300m` # 最大使用内存】
docker stats nginx
# CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT   MEM %     NET I/O     BLOCK I/O     PIDS
# 385a15a9724d   nginx     0.00%     1.961MiB / 100MiB   1.96%     656B / 0B   0B / 8.19kB   3


# 进入容器
docker exec -it 容器ID/容器名 /bin/bash
# 以交互模式启动一个容器,在容器内执行/bin/bash命令
docker run -i -t 容器ID/容器名 /bin/bash


# 查看容器日志 -t:显示时间戳
docker logs -f -t 容器ID/容器名
docker logs -fn10 -t 容器ID/容器名


# 构造镜像
# 用法 docker build -t 镜像名称 .
docker build -t docker_demo .
```
