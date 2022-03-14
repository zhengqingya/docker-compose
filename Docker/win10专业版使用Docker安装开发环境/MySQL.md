### Docker 安装 MySQL

```shell
# 拉取镜像
docker pull mysql:5.7
docker pull registry.cn-hangzhou.aliyuncs.com/zhengqing/mysql5.7

# 运行镜像 【 -e MYSQL_ROOT_PASSWORD=******：初始化root用户的密码 这里我设置密码为root 】
docker run -d -p 3306:3306 --name mysql_server --restart=always -e MYSQL_ROOT_PASSWORD=root mysql:5.7
docker run -d -p 3306:3306 --name mysql_server --restart=always -e MYSQL_ROOT_PASSWORD=root registry.cn-hangzhou.aliyuncs.com/zhengqing/mysql5.7

# 进入mysql -> 通过Portainer
mysql -uroot -proot
```

#### 问题

###### 解决插入数据出现中文乱码？？？

```shell
# 1.进入容器
docker exec -it 容器ID /bin/bash
# 2.登录mysql
mysql -uroot -proot
# 3.查看数据库编码
show variables like "%char%";
# 4.设置默认的编码格式
set names utf8; 或 set names gbk;

# 附:执行SET NAMES utf8的效果等同于同时设定如下：
SET character_set_client='utf8';
SET character_set_connection='utf8';
SET character_set_results='utf8';

# 5.修改编码
vim /etc/mysql/my.cnf   -> 5.5以后系统新增如下

[client]
default-character-set=utf8

[mysqld]
default-storage-engine=INNODB
character-set-server=utf8
collation-server=utf8_general_ci

# 6.重启mysql
/etc/init.d/mysql stop   

# 7.启动mysql容器
docker start 31b94cc4b7ec
```
