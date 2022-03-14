### Docker 安装 JDK

> 失败版！！！

```shell script
docker pull java

# 创建一个jdk目录 【注意是反斜杠哦】
mkdir E:\zhengqingya\soft\soft-dev\Docker\data\jdk

# 准备环境 -> 映射到宿主机使用

# 以交互式方式运行该容器
docker run --name java -i -t java:latest /bin/bash   

# 后台运行
docker run -d --name java --restart=always java  


# 将容器中`java-8-openjdk-amd64`下的所有文件映射到宿主机的`jdk`文件夹下
docker cp java:/usr/lib/jvm/java-8-openjdk-amd64/ E:\zhengqingya\soft\soft-dev\Docker\data\jdk 


docker run -d --name java -v /e/zhengqingya/soft/soft-dev/Docker/data/jdk/:/usr/lib/jvm/java-8-openjdk-amd64 --restart=always java
```
