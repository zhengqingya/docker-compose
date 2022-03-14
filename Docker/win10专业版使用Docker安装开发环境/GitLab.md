### 5、Docker 安装 GitLab

```shell
# 拉取gitlab镜像
docker pull gitlab/gitlab-ce:latest

# 运行GitLab 【
#                   –privileged=true 添加权限，不然无权限创建/srv/gitlab/config/gitlab.rb等配置文件
#                    宿主机目录会自动创建(/srv/gitlab/config、/srv/gitlab/logs、/srv/gitlab/data)
#            】
docker run -d  -p 443:443 -p 80:80 -p 222:22 --name gitlab --restart always -v /srv/gitlab/config:/etc/gitlab -v /srv/gitlab/logs:/var/log/gitlab -v /srv/gitlab/data:/var/opt/gitlab --privileged=true gitlab/gitlab-ce:latest
```
