# docker-compose-windows

![docker-compose-windows.png](./image/docker-compose-windows.png)

## 环境准备

Docker安装教程：[https://zhengqing.blog.csdn.net/article/details/103441358](https://zhengqing.blog.csdn.net/article/details/103441358)

> 注：建议使用`Git Bash Here`执行以下命令

```shell script
# 创建文件夹
mkdir -p D:/zhengqingya/soft/soft-dev/Docker
cd D:/zhengqingya/soft/soft-dev/Docker

git clone https://gitee.com/zhengqingya/docker-compose.git
cd docker-compose/Windows
```

## 运行服务

> 环境部署见每个服务下的`run.md`
> ex: `Windows/portainer/run.md`

## tips

windows环境下如果需要映射绝对路径，eg: `/d/test` 等同于 `D:\test`
