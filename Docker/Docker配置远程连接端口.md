### 一、修改宿主机配置文件

```shell
vim /lib/systemd/system/docker.service
```

在 `ExecStart` 开头的这一行末尾添加 `-H tcp://0.0.0.0:2375`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190822152957903.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4MjI1NTU4,size_16,color_FFFFFF,t_70)

### 二、重启docker

```shell
systemctl daemon-reload && systemctl restart docker
```

### 三、防火墙开放端口

```shell
firewall-cmd --zone=public --add-port=2375/tcp --permanent
```

### 四、通过外网访问测试成功

[http://ip地址:2375/version](http://ip%E5%9C%B0%E5%9D%80:2375/version)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190822154200163.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4MjI1NTU4,size_16,color_FFFFFF,t_70)
