# 根据overlay2下的目录名查找对应容器名

```shell
# 依次输出: 进程pid、容器ID、容器名、存储work路径
docker ps -q | xargs docker inspect --format '{{.State.Pid}}, {{.Id}}, {{.Name}}, {{.GraphDriver.Data.WorkDir}}' | grep 目录名
```

