### Docker安装

> 可参考 https://docs.docker.com/engine/install/centos
>
> tips: 基于 CentOS Linux release 7.6.1810 (Core)

```shell
# 配置yum源
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo


# 通过yum源安装docker
# sudo yum -y install docker
# 指定版本安装
sudo yum install -y docker-ce-20.10.7 docker-ce-cli-20.10.7 containerd.io-1.4.6

# 启动docker
sudo systemctl start docker
# 重启docker 
sudo systemctl restart docker
# 开机自启
sudo systemctl enable docker
# 设置开机自启 & 现在启动
sudo systemctl enable --now docker

# 查看运行情况
sudo systemctl status docker

# 测试
docker run --rm alpine ping -c 5 baidu.com
```

### Docker卸载

```shell
# 查看yum安装的docker软件包
yum list installed |grep docker
# 删除相关软件包
yum -y remove docker* containerd.io
# 删除关联数据
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
```

### 配置镜像加速器

```shell
# 修改daemon配置文件`/etc/docker/daemon.json`
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["加速器地址"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
# 查看 `Registry Mirrors`
docker info
```

---

### `docker-compose`安装

```shell
# 安装EPEL软件包
sudo yum -y install epel-release
# 安装pip3
sudo yum install -y python36-pip
# 升级
sudo pip3 install --upgrade pip
# 验证pip3版本
pip3 --version
# docker-compose安装
sudo pip3 install -U docker-compose
# 验证docker-compose版本
docker-compose --version
# 安装补全插件
# curl -L https://raw.githubusercontent.com/docker/compose/1.25.0/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
```

### `docker-compose`卸载

```shell
pip3 uninstall docker-compose
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
