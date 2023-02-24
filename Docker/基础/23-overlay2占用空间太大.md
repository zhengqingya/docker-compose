# `/var/lib/docker/overlay2`磁盘空间占用太大问题

> tips: 千万不要直接删除掉！！！ 
> 只能去删除无用镜像或其相关日志信息...
> 如果不懂此操作，建议先存个快照，避免删除重要数据！！！

### 查看docker所占的硬盘大小

```shell
docker system df
# TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
# Images          19        4         8.339GB   7.514GB (90%)
# Containers      4         4         6B        0B (0%)
# Local Volumes   1389      1         3.012GB   3.012GB (100%)
# Build Cache     0         0         0B        0B
```

### 自动清理空间

- 已停止的容器（container）
- 未被任何容器所使用的卷（volume）
- 未被任何容器所关联的网络（network）
- 所有悬空镜像（image）
- -a: 清除所有未使用的镜像和悬空镜像

```shell
docker system prune -a
```

### 清理未使用的数据卷

```shell
# 将未被使用的数据卷清理掉
docker volume prune

# 不用输入y确认
# docker volume prune -f
```

---

在docker中，默认启用了 overlay2作为文件管理系统

- lower-id 文件里面记录的是镜像层的顶层ID，也就是此层的基层 ，OverlayFS概念中的 lowerdir;
- upper 文件夹就是本层的可读写层（在 overlay2中的变成了diff）,它也就是 OverlayFS概念中的 upperdir;
- merged 文件夹是和文件夹的联合挂载，在运行中的容器看过去的文件系统就是它;
- work 文件夹则是OverlayFS内部文件;

