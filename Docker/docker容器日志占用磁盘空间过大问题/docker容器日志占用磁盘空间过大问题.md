# docker容器日志占用磁盘空间过大问题

```shell
# 查出占用磁盘较大的文件-升序
du -d1 -h /var/lib/docker/containers | sort -h
```

### 控制容器日志大小

#### 法一：运行时控制

```shell
# max-size：容器日志最大100M
# max-file：最大日志数3个（ ex: *-json.log, *-json.log.1, *-json.log.2 ）
docker run -it --log-opt max-size=100m --log-opt max-file=3 redis
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
        "max-size":"100m", "max-file":"3"
    }
}

# 重启docker
systemctl daemon-reload
systemctl restart docker
```
