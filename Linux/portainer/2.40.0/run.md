### Portainer 2.40.0

> docker 可视化管理界面工具

```shell
# 运行
docker-compose -f docker-compose.yml -p portainer up -d

# -p：项目名称
# -f：指定 docker-compose.yml 文件路径
# -d：后台启动
```

访问地址：[`http://ip地址:9000`](http://127.0.0.1:9000)

```shell
# 查看日志
docker logs -f portainer
```

说明：首次打开页面后，先创建管理员账号密码。
