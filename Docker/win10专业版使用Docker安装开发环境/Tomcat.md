### Docker 安装 Tomcat

```shell
docker pull tomcat

# 创建一个tomcat目录 【注意是反斜杠哦】
mkdir E:\zhengqingya\soft\soft-dev\Docker\data\tomcat

# 为映射到windows宿主机做准备
docker run -d --name tomcatX -p 8081:8080 --restart=always tomcat
docker cp tomcatX:/usr/local/tomcat/ E:\zhengqingya\soft\soft-dev\Docker\data\tomcat    # 将容器中tomcat下的所有文件映射到宿主机的tomcat文件夹下 

# 运行
docker run -d --name tomcatX -p 8081:8080 -v /e/zhengqingya/soft/soft-dev/Docker/data/tomcat:/usr/local/tomcat --restart=always tomcat
```
