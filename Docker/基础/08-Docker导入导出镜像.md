### 准备一个修改过后的镜像

```shell
# 拉取nginx镜像
docker pull nginx

# 运行
docker run --name nginx -d -p 8080:80 nginx

# 进入容器
docker exec -it nginx /bin/bash

# 修改
echo '<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>nginx容器运行中...</title>
</head>
<body>
    <h1> Hello World </h1>
    <p> If I were you. </p>
</body>
</html>' > /usr/share/nginx/html/index.html

# 基于容器创建一个新的镜像
# -a :提交的镜像作者；
# -c :使用Dockerfile指令来创建镜像；
# -m :提交时的说明文字；
# -p :在commit时，将容器暂停。
docker commit -m "This is my nginx image" -a "zhengqingya" nginx my-nginx:v1

# 查看自制镜像
docker images my-nginx:v1
```

### 导出镜像

```shell
docker save -o my-nginx.tar my-nginx:v1
```

### 导入镜像

```shell
# 先删除已存在的旧容器
docker rm -f nginx
# 删除旧镜像
docker rmi my-nginx:v1
docker rmi nginx


# 导入使用 `docker save` 命令导出的镜像
docker load -i my-nginx.tar
# 查看镜像
docker images
# 运行
docker run --name nginx -d -p 8080:80 my-nginx:v1
```
