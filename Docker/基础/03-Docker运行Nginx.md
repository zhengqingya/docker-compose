> 搜索nginx镜像 https://hub.docker.com/search?q=nginx&type=image

### docker拉取nginx镜像

```shell
docker pull nginx
```

### 运行

```shell
# –name 定义一个容器的名字，如果在执行docker run时没有指定Name，那么deamon会自动生成一个随机数字符串当做UUID。
# -d 标识是让 docker 容器在后台运行。
# -p 标识通知 Docker 将容器内部使用的网络端口映射到我们使用的主机上。
docker run --name nginx -d -p 8080:80 nginx
```

访问 [http://127.0.0.1:8080](http://127.0.0.1:8080)

![docker-nginx-run.png](../../image/docker-nginx-run.png)
