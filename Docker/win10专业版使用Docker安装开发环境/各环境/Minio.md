### Docker 安装 Minio

```shell
# 注： 需先将容器中的data、minio、config三个目录的内容拷贝到宿主机中再做映射处理！！！

docker run --name minio_server -d -p 9001:9000 --restart=always \
-v /e/zhengqingya/soft/soft-dev/Docker/data/minio/data:/data \
-v /e/zhengqingya/soft/soft-dev/Docker/data/minio/minio:/minio \
-v /e/zhengqingya/soft/soft-dev/Docker/data/minio/config:/root/.minio \
-e "MINIO_ACCESS_KEY=admin" \
-e "MINIO_SECRET_KEY=admin123456" \
minio/minio server /data
```
