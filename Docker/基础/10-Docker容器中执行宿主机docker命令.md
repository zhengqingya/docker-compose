# 容器中执行宿主机docker命令

将docker宿主机的docker文件和docker.sock文件挂载到容器中即可

```shell
-v /var/run/docker.sock:/var/run/docker.sock 
-v /usr/bin/docker:/usr/bin/docker
-v /usr/lib64/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7
```

---

```shell
# 把docker相关的命令和依赖使用-v挂载到容器
docker run -it -d  \
--restart=always -u root \
-v /usr/bin/docker:/usr/bin/docker \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/lib64/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7 镜像名称


-u root          
#以root的身份去运行镜像(避免在容器中调用Docker命令没有权限)
#最好使用docker用户去运行

-v /usr/bin/docker:/usr/bin/docker
#将宿主机的docker命令挂载到容器中
#可以使用which docker命令查看具体位置
#或者把挂载的参数改为: -v $(which docker):/usr/bin/docker

-v /var/run/docker.sock:/var/run/docker.sock
#容器中的进程可以通过它与Docker守护进程进行通信

-v /usr/lib64/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7
#libltdl.so.7是Docker命令执行所依赖的函数库
#容器中library的默认目录是 /usr/lib/x86_64-linux-gnu/
#把宿主机的libltdl.so.7 函数库挂载到该目录即可
#可以通过whereis libltdl.so.7命令查看具体位置
#centos7位置/usr/lib64/libltdl.so.7
#ubuntu位置/usr/lib/x86_64-linux-gnu/libltdl.so.7
```

###### 举例

```shell
docker run -d -p 3307:3306 --name docker_test \
-v /usr/bin/docker:/usr/bin/docker \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/lib64/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7 \
-e MYSQL_ROOT_PASSWORD=root \
registry.cn-hangzhou.aliyuncs.com/zhengqing/mysql:5.7
```
