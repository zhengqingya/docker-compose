### Docker 安装 GitLab

> GitLab要求至少4GB内存运行，服务器配置太低的可能会出现如下情况导致运行不了

```shell
# 拉取gitlab镜像
docker pull gitlab/gitlab-ce:latest

# 运行GitLab 【
#                   –privileged=true 添加权限，不然无权限创建/srv/gitlab/config/gitlab.rb等配置文件
#                    宿主机目录会自动创建(/srv/gitlab/config、/srv/gitlab/logs、/srv/gitlab/data)
#                   -d：后台运行
#                   -p：将容器内部端口向外映射 [80:http协议 443:https协议 22:ssh协议]
#                   --name：重命名容器
#                   -v：将容器内数据、日志、配置等文件夹挂载到宿主机指定目录 也就是第二步中创建的3个目录
#            】
docker run -d  -p 443:443 -p 80:80 -p 222:22 --name gitlab --restart always -v /zhengqingya/soft/gitlab/data:/var/opt/gitlab -v /zhengqingya/soft/gitlab/config:/etc/gitlab -v /zhengqingya/soft/gitlab/logs:/var/log/gitlab --privileged=true gitlab/gitlab-ce:latest
```

|             宿主机目录            |    容器目录      |      作用      |
| -------------------------------- | --------------- | ------------- |
| /zhengqingya/soft/gitlab/config | /etc/gitlab     | gitlab配置文件 |
| /zhengqingya/soft/gitlab/data   | /var/opt/gitlab | 日志           |
| /zhengqingya/soft/gitlab/logs   | /var/log/gitlab | 应用数据       |
