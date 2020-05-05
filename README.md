### `docker-compose`安装

```shell
# 安装依赖
yum -y install epel-release
# 安装PIP
yum -y install python-pip
# 升级PIP
pip install --upgrade pip
# 验证pip 版本
pip --version
# 安装docker compose
pip install -U docker-compose==1.25.0
# 验证docker compose版本
docker-compose --version
# 安装补全插件
curl -L https://raw.githubusercontent.com/docker/compose/1.25.0/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
```

### `docker-compose`卸载

```shell
# pip卸载
pip uninstall docker-compose
```

### `docker-compose`相关命令

```shell
# 构建镜像
docker-compose build
# 构建镜像，--no-cache表示不用缓存，否则在重新编辑Dockerfile后再build可能会直接使用缓存而导致新编辑内容不生效
docker-compose build --no-cache
# config 校验文件格式是否正确
docker-compose -f docker-compose.yml config
# 运行服务
ocker-compose up -d
# 启动/停止服务
docker-compose start/stop 服务名
# 停止服务
docker-compose down
# 查看容器日志
docker logs -f 容器ID
# 查看镜像
docker-compose images
# 拉取镜像
docker-compose pull 镜像名
```

### 常用shell组合

```shell
# 删除所有容器
docker stop `docker ps -q -a` | xargs docker rm
# 删除所有标签为none的镜像
docker images|grep \<none\>|awk '{print $3}'|xargs docker rmi
# 查找容器IP地址
docker inspect 容器名或ID | grep "IPAddress"
# 创建网段, 名称: mynet, 分配两个容器在同一网段中 (这样子才可以互相通信)
docker network create mynet
docker run -d --net mynet --name container1 my_image
docker run -it --net mynet --name container1 another_image
```

---

### 环境准备

```shell
git clone https://gitee.com/zhengqingya/docker-compose.git
cd docker-compose
```

====================================================================================
=========================  ↓↓↓↓↓↓ 环境部署 start ↓↓↓↓↓↓  =============================
====================================================================================

### portainer

```shell
docker-compose -f docker-compose-portainer.yml -p portainer up -d

-p：项目名称
-f：指定docker-compose.yml文件路径
-d：后台启动
```

访问地址：[`ip地址:9000`](www.zhengqingya.com:9000)

### mysql

```shell
docker-compose -f docker-compose-mysql.yml -p mysql up -d
```

### oracle18c

```shell
docker-compose -f docker-compose-oracle18c.yml -p oracle18c up -d
```

> 配置参考：[Docker(9) 安装Oracle18c](https://zhengqing.blog.csdn.net/article/details/103296040)

### jenkins

```shell
docker-compose -f docker-compose-jenkins.yml -p jenkins up -d
```

访问地址：[`ip地址:8080`](www.zhengqingya.com:8080)

### jrebel

```shell
docker-compose -f docker-compose-jrebel.yml -p jrebel up -d
```

默认反代`idea.lanyus.com`, 运行起来后

1. 激活地址： `ip地址:8888/UUID` -> 注：UUID可以自己生成，并且必须是UUID才能通过验证 -> [UUID在线生成](http://www.uuid.online/)
2. 邮箱随意填写

### redis

```shell
docker-compose -f docker-compose-redis.yml -p redis up -d
```

连接redis

```shell
docker exec -it redis redis-cli -a 123456  # 密码为123456
```

### nginx

```shell
docker-compose -f docker-compose-nginx.yml -p nginx up -d
```

访问地址：[`ip地址:80`](www.zhengqingya.com:80)

### elasticsearch

```shell
docker-compose -f docker-compose-elasticsearch.yml -p elasticsearch up -d
```

### rabbitmq

```shell
docker-compose -f docker-compose-rabbitmq.yml -p rabbitmq up -d
```

web管理端：[`ip地址:15672`](www.zhengqingya.com:15672)
登录账号密码：`admin/admin`

### activemq

```shell
docker-compose -f docker-compose-activemq.yml -p activemq up -d
```

访问地址：[`ip地址:8161`](www.zhengqingya.com:8161)
登录账号密码：`admin/admin`

### baidupcs-web

```shell
docker-compose -f docker-compose-baidupcs-web.yml -p baidupcs-web up -d
```

访问地址：[`ip地址:5299`](www.zhengqingya.com:5299)

### nacos

```shell
docker-compose -f docker-compose-nacos.yml -p nacos up -d
```

访问地址：[`ip地址:8848/nacos`](www.zhengqingya.com:8848/nacos)
登录账号密码默认：`nacos/nacos`

### sentinel

```shell
docker-compose -f docker-compose-sentinel.yml -p sentinel up -d
```

访问地址：[`ip地址:8858`](www.zhengqingya.com:8858)
登录账号密码：`sentinel/sentinel`

### minio

```shell
docker-compose -f docker-compose-minio.yml -p minio up -d
```

访问地址：[`ip地址:9000/minio`](www.zhengqingya.com:9000/minio)
登录账号密码：`root/password`


### kafka

```shell
docker-compose -f docker-compose-kafka.yml -p kafka up -d
```

集群管理地址：[`ip地址:9000`](www.zhengqingya.com:9000)


==============================================================================
========================  ↑↑↑↑↑↑ 环境部署 end ↑↑↑↑↑↑  ==========================
==============================================================================
