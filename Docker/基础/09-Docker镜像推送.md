# 镜像推送

```shell
# 获取镜像
docker pull 镜像仓库地址


# 登录阿里云仓库
docker login -u 用户名 -p 密码 registry.cn-hangzhou.aliyuncs.com


# 将本地镜像名 改为 一个新镜像仓库地址
docker tag 镜像名 新镜像仓库地址
# 推送镜像
docker push 新镜像仓库地址
```

---

举例

```shell
docker pull nginx
docker tag nginx registry.cn-hangzhou.aliyuncs.com/zhengqing/nginx:latest
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/nginx:latest
```
