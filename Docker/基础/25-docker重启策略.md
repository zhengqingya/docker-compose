# docker重启策略

- `--restart=no` 默认策略，在容器退出时不重启容器
- `--restart=on-failure` 在容器非正常退出时（退出状态非0），才会重启容器
- `--restart=on-failure:3` 指定启动的次数，在容器非正常退出时重启容器，最多重启3次
- `--restart=always` 在容器退出时总是重启容器
- `--restart=unless-stopped` 在容器退出时总是重启容器，但是不考虑在Docker守护进程启动时就已经停止了的容器

```shell
# ex: 
docker run -d -p 9000:9000 --restart=always --name portainer -v /var/run/docker.sock:/var/run/docker.sock registry.cn-hangzhou.aliyuncs.com/zhengqing/portainer:1.25.0
```
