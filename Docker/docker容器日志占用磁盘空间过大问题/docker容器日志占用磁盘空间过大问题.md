# docker容器日志占用磁盘空间过大问题

```shell
# 查询占用磁盘较大的文件-升序
du -d1 -h /var/lib/docker/containers | sort -h
```

### 控制容器日志大小

#### 法一：运行时控制

##### docker

```shell
# max-size：容器日志最大100M
# max-file：最大日志数3个（ ex: *-json.log, *-json.log.1, *-json.log.2 ）
docker run -it --log-opt max-size=100m --log-opt max-file=3 redis
```

日志目录`/var/lib/docker/containers`
![img.png](images/docker-log.png)

观察日志的增长，你会发现当`xxx.log`日志文件到达设置的最大日志量后，会变成`xxx.log.1`，`xxx.log.2`文件...

##### docker-compose

```shell
version: '3'

services:
  test:
    image: xxx
    # 日志
    logging:
      driver: "json-file"   # 默认的文件日志驱动
      options:
        max-size: "100m"    # 单个日志文件大小为100m
        max-file: "3"       # 最多3个日志文件
```

#### 法二：全局配置

> 温馨小提示：新容器生效

```shell
# 创建或修改`daemon.json`文件
cat /etc/docker/daemon.json

# 新增如下配置
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size":"100m", 
        "max-file":"3"
    }
}

# 重启docker
systemctl daemon-reload
systemctl restart docker
```
