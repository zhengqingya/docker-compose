# 解决Docker容器内无法访问外网问题

> tips: 由于环境不同，问题的解决方法也自然不同，下面是小编所在环境的解决方式 `^_^`

#### 法一：重建网络`docker0`

```shell
sudo service docker stop
sudo pkill docker
sudo iptables -t nat -F
sudo ifconfig docker0 down
sudo brctl delbr docker0
sudo service docker start
```

#### 法二：开启宿主机的ipv4转发功能

```shell
# 修改配置
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# 重启network
systemctl restart network

# 查看 (0->标识未开启 1->标识开启)
sysctl net.ipv4.ip_forward
# net.ipv4.ip_forward = 1

# 重启docker
systemctl restart docker
```

#### 法三：使用`--net=host`宿主机网络方式启动容器

```shell
# 示例
docker run --net=host --name ubuntu_bash -i -t ubuntu:latest /bin/bash

docker run --net=host --rm alpine ping -c 5 baidu.com
```

#### 法四：关闭SELinux

```shell
# 查看SELinux状态
getenforce

# 临时关闭SELinux
setenforce 0

# 永久关闭SELinux
vim /etc/selinux/config
# 将 `SELINUX=enforcing` 改成 `SELINUX=disabled`

# 重启liunx
reboot
```

#### 法五

> 参考 https://github.com/coolsnowwolf/lede/issues/1760

```shell
# 修改配置
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-arptables = 1" >> /etc/sysctl.conf

# Luci > 网络 > 防火墙 > 转发：接受
# Luci > 状态 > 防火墙 > 重启防火墙

service docker restart
```

#### 法六：

```shell
rm -rf /var/lib/docker/network/*

systemctl restart docker
```


#### 法七：重装docker

> 此方式乃是最后无奈之举了...


---

#### 临时测试容器内能够ping

```shell
docker run --rm alpine ping -c 5 baidu.com
```
