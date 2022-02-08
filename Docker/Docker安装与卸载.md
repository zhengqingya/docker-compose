### Docker安装

> 可参考 https://docs.docker.com/engine/install/centos

```shell
# 通过yum源安装docker
# sudo yum -y install docker
sudo yum install docker-ce
# 启动docker
sudo systemctl start docker
# 开机自启
sudo systemctl enable docker
```

### Docker卸载

```shell
# 查看yum安装的docker文件包
yum list installed |grep docker
# 查看docker相关的rpm源文件
rpm -qa |grep docker
# 删除所有安装的docker文件包 注：docker-ce根据上面查询显示的名称来选择 ex:"docker-ce.x86_64 0:18.06.0.ce-3.el7"
yum -y remove docker-ce*
sudo yum remove docker  docker-common docker-selinux docker-engine
# 删除docker的镜像文件，默认在/var/lib/docker目录下 
rm -rf /var/lib/docker
```


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
