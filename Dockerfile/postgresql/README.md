### 使用示例命令

1. 拉取 https://gitee.com/plumeorg/plumelog 代码
2. 打包 plumelog-server   ( tips: 打包时需要注释`application.properties`配置文件内容，这样外部配置文件才会生效... )
3. 执行以下命令制作镜像

```shell
# 打包镜像 -f:指定Dockerfile文件路径 --no-cache:构建镜像时不使用缓存
docker build -f Dockerfile -t "ccr.ccs.tencentyun.com/xuzhijun/postgresql:16.3-pgvector" . --no-cache

# 推送镜像
docker push ccr.ccs.tencentyun.com/xuzhijun/postgresql:16.3-pgvector
```
