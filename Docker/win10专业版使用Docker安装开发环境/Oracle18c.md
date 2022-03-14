### Docker 安装 Oracle18c

> 经尝试windows上无法安装！！！

```shell
# 1.拉取镜像
# docker pull ynraju4/oracle18c
docker pull registry.cn-hangzhou.aliyuncs.com/zhengqing/oracle18c

# 2.创建一个data目录映射oracle18c容器数据  【注意是反斜杠哦】
mkdir E:\zhengqingya\soft\soft-dev\Docker\data\db\oracle18c\data

# 3.运行
docker run -d --name oracle18c -p 1521:1521 --restart always -v /e/zhengqingya/soft/soft-dev/Docker/data/db/oracle18c/data:/opt/oracle registry.cn-hangzhou.aliyuncs.com/zhengqing/oracle18c

# 注：如果运行时报 `/bin/sh: /opt/oracle/runOracle.sh: No such file or directory` 则直接执行如下命令，不映射目录
docker run -d --name oracle18c -p 1521:1521 --restart always registry.cn-hangzhou.aliyuncs.com/zhengqing/oracle18c 

# 4.进入容器设置密码 -> 通过Portainer
./setPassword.sh 123456 # 123456为设置密码，这里修改为自己的即可

# 5.依次执行如下命令进入oracle并设置 PDB
grep $ORACLE_HOME /etc/oratab | cut -d: -f1
export ORACLE_SID=ORCLCDB
sqlplus / as sysdba

# 6.设置pdb
show pdbs;
alter session set container=ORCLPDB1;

# 7.注：每次登录都要设置 ORACLE_SID 环境变量，可以将这个写到~/.bashrc文件里去 ，执行如下命令
host echo "export ORACLE_SID=ORCLCDB" >> ~/.bashrc

# 8.最后测试登录
sqlplus 用户名/密码@服务名     # ex: sqlplus SYS/123456@ORCLPDB1

# 9.Navicat远程连接测试
```
