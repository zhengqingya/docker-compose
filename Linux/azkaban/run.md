# Azkaban

- https://github.com/azkaban/azkaban
- https://azkaban.github.io

Azkaban 是一个开源的批处理工作流调度系统，用于管理和调度Hadoop生态系统中的任务和作业。

> tips：部署未成功

```shell
# 拿到sql文件
# docker cp azkaban-exec:/opt/apache/azkaban-3.91.0-313/azkaban-db/create-all-sql-3.91.0-313-gadb56414.sql ./create-all-sql-3.91.0-313-gadb56414.sql
# mysql建库 azkaban 并导入 create-all-sql-3.91.0-313-gadb56414.sql

# 运行 -- tips:先修改conf目录下的配置文件信息
docker-compose -f docker-compose-azkaban.yml -p azkaban up -d

# 查看对外端口
docker-compose -p=azkaban ps
```

- web访问地址：`http://127.0.0.1:8081`
- 默认登录账号密码：`azkaban/azkaban`

