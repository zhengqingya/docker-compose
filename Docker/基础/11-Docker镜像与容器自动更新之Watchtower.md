# 自动更新Docker镜像与容器 - Watchtower

### 自动清除旧镜像

> 每次更新都会把旧的镜像清理掉, `--cleanup` 选项可以简写为 `-c`

```shell script
docker run -d \
    --name watchtower \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup
```

### 选择性自动更新

> ex: 只自动更新`nginx` 和 `redis` 容器

```shell script
docker run -d \
    --name watchtower \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower -c \
    nginx redis
```

可以建立一个更新列表文件, 然后通过变量的方式去调用这个列表

```shell script
cd /zhengqingya/soft/docker
# ① 
echo 'small-tools
      code-api' > watchtower.list

# ② 
docker run -d \
    --name watchtower \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower -c \
    $(cat ~/.watchtower.list)
```

### 设置自动更新检查频率

> 默认情况下 Watchtower 每 5 分钟会轮询一次，如果你觉得这个频率太高了可以使用如下选项来控制更新检查的频率，但二者只能选择其一
> --interval, -i - 设置更新检测时间间隔，单位为秒。比如每隔 1 个小时检查一次更新

```shell script
docker run -d \
    --name watchtower \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower -c \
    --interval 3600
```

> --schedule, -s - 设置定时检测更新时间。格式为 6 字段 Cron 表达式，而非传统的 5 个字段。比如每天凌晨 2 点检查一次更新

```shell script
docker run -d \
    --name watchtower \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower -c \
    --schedule "0 2 * * * *"
```

### 最终实战命令

```shell script
docker run -d \
    --name watchtower \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower -c \
    $(cat $PWD/watchtower.list) \
    -i 30
```
