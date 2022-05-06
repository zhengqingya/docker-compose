# 容器和宿主机文件互传

```shell
# 从容器里面拷文件到宿主机  前：容器文件路径  后：宿主机路径
docker cp 容器ID/容器名:容器文件路径 宿主机文件路径

# 从宿主机拷文件到容器里面  前：宿主机文件路径 后：容器路径
docker cp 宿主机文件路径 容器ID/容器名:容器文件路径
```

ex:

```shell
# 从容器`mysql`里面拷文件到宿主机  前：容器文件路径  后：宿主机路径
docker cp mysql:/tmp/all.sql /tmp/all.sql

# 从宿主机拷文件到容器`mysql`里面  前：宿主机文件路径 后：容器路径
docker cp /tmp/all.sql mysql:/tmp/all.sql
```
