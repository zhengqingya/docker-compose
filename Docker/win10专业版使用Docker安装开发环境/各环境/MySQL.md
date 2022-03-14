### Docker 安装 MySQL

```shell
# 查看镜像
docker search mysql

# 拉取镜像
# docker pull mysql:5.7
docker pull registry.cn-hangzhou.aliyuncs.com/zhengqing/mysql5.7


mkdir -p /zhengqingya/soft/mysql/mysql
mkdir -p /zhengqingya/soft/mysql/mysql/conf.d
mkdir -p /zhengqingya/soft/mysql/mysql/data

cd /zhengqingya/soft/mysql/mysql


# echo:如果没有这个文件则创建。如果有这个文件，那么新内容将会代替原来的内容
echo '[mysqld]
user=mysql                     # MySQL启动用户
default-storage-engine=INNODB  # 创建新表时将使用的默认存储引擎
character-set-server=utf8      # 设置mysql服务端默认字符集
pid-file        = /var/run/mysqld/mysqld.pid  # pid文件所在目录
socket          = /var/run/mysqld/mysqld.sock # 用于本地连接的socket套接字
datadir         = /var/lib/mysql              # 数据文件存放的目录
#log-error      = /var/log/mysql/error.log
#bind-address   = 127.0.0.1                   # MySQL绑定IP
expire_logs_days=7                            # 定义清除过期日志的时间(这里设置为7天)
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION # 定义mysql应该支持的sql语法，数据校验等!
# lower_case_table_names=1          # 解决Linux系统下Mysql数据表大小写敏感问题（0:大小写敏感;1:大小写不敏感）

# 允许最大连接数
max_connections=200

# ================= ↓↓↓ mysql主从同步配置start ↓↓↓ =================
# 同一局域网内注意要唯一
#server-id=3310
# 开启二进制日志功能
#log-bin=mysql-bin
# ================= ↑↑↑ mysql主从同步配置end ↑↑↑ =================

[client]
default-character-set=utf8  # 设置mysql客户端默认字符集
' > my.cnf

# 运行镜像
docker run --name mysql_server -d -p 3307:3306 --restart=always -v /zhengqingya/soft/mysql/mysql/data/:/var/lib/mysql -v /zhengqingya/soft/mysql/mysql/conf.d:/etc/mysql/conf.d -v /zhengqingya/soft/mysql/mysql/my.cnf:/etc/mysql/my.cnf -e MYSQL_ROOT_PASSWORD=zhengqing registry.cn-hangzhou.aliyuncs.com/zhengqing/mysql5.7

# -d 标识是让 docker 容器在后台运行。
# -p 标识通知 Docker 将容器内部使用的网络端口映射到我们使用的主机上。
# –name 定义一个容器的名字，如果在执行docker run时没有指定Name，那么deamon会自动生成一个随机数字符串当做UUID。
# -e 设置环境变量，或者覆盖已存在的环境变量
#         -e MYSQL_ROOT_PASSWORD=******：初始化root用户的密码 这里我设置密码为root
# 3307:3306 将容器的3307端口映射到本机的3306端口


# 进入mysql
docker exec -it mysql_server /bin/bash
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

###### 本地连接时报1130错误 -> 没有分配权限

```
ERROR 1130: Host xxx.xxx.xxx.xxx is not allowed to connect to this MySQL server  =>  无法给远程连接的用户权限问题
```

```
# 给用户授权
GRANT ALL PRIVILEGES ON . TO ‘用户名’@’%’ IDENTIFIED BY ‘密码’ WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON . TO ‘root’@’%’ IDENTIFIED BY ‘root’ WITH GRANT OPTION;

# 刷新权限
flush privileges; 
```
