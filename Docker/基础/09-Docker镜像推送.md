# 镜像推送

```shell
# 登录认证仓库
docker login -u 用户名 -p 密码 仓库地址

# 获取镜像
docker pull 镜像仓库地址

# 将本地镜像名 改为 一个新镜像仓库地址
docker tag 镜像名 新镜像仓库地址

# 推送镜像
docker push 新镜像仓库地址
```

---

举例

```shell
# 认证harbor私服
docker login -u admin -p Harbor12345 harbor.zhengqingya.com:11000

docker pull nginx

docker tag nginx harbor.zhengqingya.com:11000/zhengqing/nginx:latest

docker push harbor.zhengqingya.com:11000/zhengqing/nginx:latest
```
