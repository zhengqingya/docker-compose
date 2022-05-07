### 一、前言

Harbor是一个用于存储和分发Docker镜像的企业级Registry服务器。

本文将基于docker和docker-compose环境简单部署Harbor，并通过docker推送/拉取镜像操作

1. Docker version 20.10.8, build 3967b7d
2. docker-compose version 1.29.2, build 5becea4c

### 二、部署Harbor

```shell
# 进入自己的安装目录
cd /Users/zhengqingya/IT_zhengqing/soft/soft-dev/Docker

# 下载： https://github.com/goharbor/harbor/releases/
wget https://github.com/goharbor/harbor/releases/download/v2.3.2/harbor-offline-installer-v2.3.2.tgz

# 解压
tar xvf harbor-offline-installer-v2.3.2.tgz

# 进入harbor
cd harbor

# 拷贝配置文件`harbor.yml`
cp harbor.yml.tmpl harbor.yml
# 修改配置(可参考后面给出的demo)
vim harbor.yml

# 安装
./install.sh
```

`harbor.yml`配置demo

> 温馨小提示：根据自己的情况修改即可~

```yml
# Configuration file of Harbor

# The IP address or hostname to access admin UI and registry service.
# DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
hostname: harbor.zhengqingya.com

# http related config
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 11000

# https related config
# https:
#   # https port for harbor, default is 443
#   port: 443
#   # The path of cert and key files for nginx
#   certificate: /your/certificate/path
#   private_key: /your/private/key/path

# # Uncomment following will enable tls communication between all harbor components
# internal_tls:
#   # set enabled to true means internal tls is enabled
#   enabled: true
#   # put your cert and key files on dir
#   dir: /etc/harbor/tls/internal

# Uncomment external_url if you want to enable external proxy
# And when it enabled the hostname will no longer used
# external_url: https://reg.mydomain.com:8433
external_url: http://harbor.zhengqingya.com:11000

# The initial password of Harbor admin
# It only works in first time to install harbor
# Remember Change the admin password from UI after launching Harbor.
harbor_admin_password: Harbor12345

# Harbor DB configuration
database:
  # The password for the root user of Harbor DB. Change this before any production use.
  password: root123
  # The maximum number of connections in the idle connection pool. If it <=0, no idle connections are retained.
  max_idle_conns: 100
  # The maximum number of open connections to the database. If it <= 0, then there is no limit on the number of open connections.
  # Note: the default number of connections is 1024 for postgres of harbor.
  max_open_conns: 900

# The default data volume
data_volume: /Users/zhengqingya/IT_zhengqing/soft/soft-dev/Docker/harbor/data

# Harbor Storage settings by default is using /data dir on local filesystem
# Uncomment storage_service setting If you want to using external storage
# storage_service:
#   # ca_bundle is the path to the custom root ca certificate, which will be injected into the truststore
#   # of registry's and chart repository's containers.  This is usually needed when the user hosts a internal storage with self signed certificate.
#   ca_bundle:

#   # storage backend, default is filesystem, options include filesystem, azure, gcs, s3, swift and oss
#   # for more info about this configuration please refer https://docs.docker.com/registry/configuration/
#   filesystem:
#     maxthreads: 100
#   # set disable to true when you want to disable registry redirect
#   redirect:
#     disabled: false

# Trivy configuration
#
# Trivy DB contains vulnerability information from NVD, Red Hat, and many other upstream vulnerability databases.
# It is downloaded by Trivy from the GitHub release page https://github.com/aquasecurity/trivy-db/releases and cached
# in the local file system. In addition, the database contains the update timestamp so Trivy can detect whether it
# should download a newer version from the Internet or use the cached one. Currently, the database is updated every
# 12 hours and published as a new release to GitHub.
trivy:
  # ignoreUnfixed The flag to display only fixed vulnerabilities
  ignore_unfixed: false
  # skipUpdate The flag to enable or disable Trivy DB downloads from GitHub
  #
  # You might want to enable this flag in test or CI/CD environments to avoid GitHub rate limiting issues.
  # If the flag is enabled you have to download the `trivy-offline.tar.gz` archive manually, extract `trivy.db` and
  # `metadata.json` files and mount them in the `/home/scanner/.cache/trivy/db` path.
  skip_update: false
  #
  # insecure The flag to skip verifying registry certificate
  insecure: false
  # github_token The GitHub access token to download Trivy DB
  #
  # Anonymous downloads from GitHub are subject to the limit of 60 requests per hour. Normally such rate limit is enough
  # for production operations. If, for any reason, it's not enough, you could increase the rate limit to 5000
  # requests per hour by specifying the GitHub access token. For more details on GitHub rate limiting please consult
  # https://developer.github.com/v3/#rate-limiting
  #
  # You can create a GitHub token by following the instructions in
  # https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line
  #
  # github_token: xxx

jobservice:
  # Maximum number of job workers in job service
  max_job_workers: 10

notification:
  # Maximum retry count for webhook job
  webhook_job_max_retry: 10

chart:
  # Change the value of absolute_url to enabled can enable absolute url in chart
  absolute_url: disabled

# Log configurations
log:
  # options are debug, info, warning, error, fatal
  level: info
  # configs for logs in local storage
  local:
    # Log files are rotated log_rotate_count times before being removed. If count is 0, old versions are removed rather than rotated.
    rotate_count: 50
    # Log files are rotated only if they grow bigger than log_rotate_size bytes. If size is followed by k, the size is assumed to be in kilobytes.
    # If the M is used, the size is in megabytes, and if G is used, the size is in gigabytes. So size 100, size 100k, size 100M and size 100G
    # are all valid.
    rotate_size: 200M
    # The directory on your host that store log
    location: /Users/zhengqingya/IT_zhengqing/soft/soft-dev/Docker/harbor/log

  # Uncomment following lines to enable external syslog endpoint.
  # external_endpoint:
  #   # protocol used to transmit log to external endpoint, options is tcp or udp
  #   protocol: tcp
  #   # The host of external endpoint
  #   host: localhost
  #   # Port of external endpoint
  #   port: 5140

#This attribute is for migrator to detect the version of the .cfg file, DO NOT MODIFY!
_version: 2.3.0

# Uncomment external_database if using external database.
# external_database:
#   harbor:
#     host: harbor_db_host
#     port: harbor_db_port
#     db_name: harbor_db_name
#     username: harbor_db_username
#     password: harbor_db_password
#     ssl_mode: disable
#     max_idle_conns: 2
#     max_open_conns: 0
#   notary_signer:
#     host: notary_signer_db_host
#     port: notary_signer_db_port
#     db_name: notary_signer_db_name
#     username: notary_signer_db_username
#     password: notary_signer_db_password
#     ssl_mode: disable
#   notary_server:
#     host: notary_server_db_host
#     port: notary_server_db_port
#     db_name: notary_server_db_name
#     username: notary_server_db_username
#     password: notary_server_db_password
#     ssl_mode: disable

# Uncomment external_redis if using external Redis server
# external_redis:
#   # support redis, redis+sentinel
#   # host for redis: <host_redis>:<port_redis>
#   # host for redis+sentinel:
#   #  <host_sentinel1>:<port_sentinel1>,<host_sentinel2>:<port_sentinel2>,<host_sentinel3>:<port_sentinel3>
#   host: redis:6379
#   password:
#   # sentinel_master_set must be set to support redis+sentinel
#   #sentinel_master_set:
#   # db_index 0 is for core, it's unchangeable
#   registry_db_index: 1
#   jobservice_db_index: 2
#   chartmuseum_db_index: 3
#   trivy_db_index: 5
#   idle_timeout_seconds: 30

# Uncomment uaa for trusting the certificate of uaa instance that is hosted via self-signed cert.
# uaa:
#   ca_file: /path/to/ca

# Global proxy
# Config http proxy for components, e.g. http://my.proxy.com:3128
# Components doesn't need to connect to each others via http proxy.
# Remove component from `components` array if want disable proxy
# for it. If you want use proxy for replication, MUST enable proxy
# for core and jobservice, and set `http_proxy` and `https_proxy`.
# Add domain to the `no_proxy` field, when you want disable proxy
# for some special registry.
proxy:
  http_proxy:
  https_proxy:
  no_proxy:
  components:
    - core
    - jobservice
    - trivy

# metric:
#   enabled: false
#   port: 9090
#   path: /metrics
```


安装成功如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/680b622d28d14ea48ff01a6567eea8ee.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)
访问 [http://127.0.0.1:11000](http://127.0.0.1:11000)，登录`admin/Harbor12345`
![在这里插入图片描述](https://img-blog.csdnimg.cn/a8b1c02201fa4ecbbb226af713a738c6.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)
界面就自己多点点玩吧 `^_^`
![在这里插入图片描述](https://img-blog.csdnimg.cn/05bdee499ed34d98aeedb36084b993ba.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)
这里新建项目`test`，后面docker测试推送镜像需要，否则后面会报错: `unauthorized: project test not found: project test not found`
![在这里插入图片描述](https://img-blog.csdnimg.cn/a380af078133494db937a14a8cccca45.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)


其它：

```shell
# 温馨小提示：在harbor安装目录下执行如下命令

# 运行harbor
docker-compose start

# 停止harbor
docker-compose stop
# 删除harbor
docker-compose rm
```


### 三、docker推送/拉取镜像

#### 1、docker登录harbor

```shell
docker login -u admin -p Harbor12345 127.0.0.1:11000
# 通过ip认证需要配置`/etc/docker/daemon.json`
# docker login -u admin -p Harbor12345 192.168.101.90:11000
```

报错如下
![在这里插入图片描述](https://img-blog.csdnimg.cn/4fe01319ad7049d8afeee6fd2676157c.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)
解决

> 可参考： [https://goharbor.io/docs/2.3.0/install-config/run-installer-script/#connect-http](https://goharbor.io/docs/2.3.0/install-config/run-installer-script/#connect-http)

###### 法一：{ "insecure-registries":["harbor的ip:port"] }

```shell
sudo vim /etc/docker/daemon.json
# 新增配置 { "insecure-registries":["harbor的ip:port"] }
{
   "insecure-registries": [ "192.168.101.90:11000" ] 
}

# 加载配置文件
systemctl daemon-reload
# 重启docker
systemctl restart docker
```

###### 法二：hosts解析

> 此方式，小编本地尝试直接过，修改hosts之后即可生效，尝试登录harbor，很爽`^_^`

```shell
sudo vim /etc/hosts
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/9ccd95703cf543f587d21c1976dce430.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)
再次登录，成功！

```shell
docker login -u admin -p Harbor12345 harbor.zhengqingya.com:11000
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/13c36c65816c46cdb7627a3da2538865.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)


#### 2、docker推送镜像

```shell
# docker tag SOURCE_IMAGE[:TAG] harbor.zhengqingya.com:11000/test/REPOSITORY[:TAG]
docker tag registry.cn-hangzhou.aliyuncs.com/zhengqing/portainer:1.24.1 127.0.0.1:11000/test/portainer:1.24.1
# docker push harbor.zhengqingya.com:11000/test/REPOSITORY[:TAG]
docker push 127.0.0.1:11000/test/portainer:1.24.1
```

推送成功如下
![在这里插入图片描述](https://img-blog.csdnimg.cn/6cc2e85f0ca34cf09568e66771a80359.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)
harbor中查看
![在这里插入图片描述](https://img-blog.csdnimg.cn/4471ca2b7390407ab7faa72a18804ea5.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA6YOR5riF,size_20,color_FFFFFF,t_70,g_se,x_16)


#### 3、docker拉取镜像

```shell
docker pull 127.0.0.1:11000/test/portainer:1.24.1
```


### 四、其它

安装harbor报错如下：

```
prepare base dir is set to /Users/zhengqingya/IT_zhengqing/soft/soft-dev/Docker/harbor
Error happened in config validation...
ERROR:root:Error: The protocol is https but attribute ssl_cert is not set
```

解决：注释https相关

```yml
# https related config
# https:
#   # https port for harbor, default is 443
#   port: 443
#   # The path of cert and key files for nginx
#   certificate: /your/certificate/path
#   private_key: /your/private/key/path
```


---

> 今日分享语句：
> 不要自卑,你不比别人笨。
> 不要自满,别人不比你笨。
