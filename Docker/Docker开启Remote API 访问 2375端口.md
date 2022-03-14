# Docker开启Remote API 访问 2375端口

Docker常见端口

```
2375：未加密的docker socket,远程root无密码访问主机
2376：tls加密套接字,很可能这是您的CI服务器4243端口作为https 443端口的修改
2377：群集模式套接字,适用于群集管理器,不适用于docker客户端
5000：docker注册服务
4789和7946：覆盖网络
```

tips： 最后如果还是不能访问则在服务器执行命令 -> `iptables -I INPUT -p tcp --dport 2375 -j ACCEPT`  开放2375端口

```shell
# ① ----------------------------------------------
vim /etc/docker/daemon.json

{
  "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]
}

systemctl daemon-reload
systemctl restart docker

# ② ----------------------------------------------
vim /usr/lib/systemd/system/docker.service

ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock

systemctl daemon-reload
systemctl restart docker

# ③ ----------------------------------------------
sudo vim /etc/default/docker
# 加入下面一行
DOCKER_OPTS="-H tcp://0.0.0.0:2375"

sudo systemctl restart docker
# ------------------------------------------

# 查看docker版本
docker -H tcp://www.zhengqingya.com:2375 version
# 查看镜像包
docker -H tcp://www.zhengqingya.com:2375 images
```
