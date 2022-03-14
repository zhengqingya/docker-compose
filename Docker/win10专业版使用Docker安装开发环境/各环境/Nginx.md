### 前言：【centos7】彻底卸载Nginx

```shell
# 停止Nginx服务
/usr/local/nginx/sbin/nginx -s stop

yum remove nginx

# 查看Nginx相关文件
whereis nginx  
# 或
which nginx

# 删除
rm -rf /usr/local/nginx

# 如果设置了Nginx开机自启动的话，可能还需要下面两步
chkconfig nginx off
rm -rf /etc/init.d/nginx
```

---

# Docker 安装 Nginx

> tips: 这篇安装偏啰嗦!!!

### 一、拉取官方的镜像

```shell
docker pull nginx
```

### 二、创建宿主机目录nginx -> 用于挂载下面在容器中找到的配置文件

> 温馨小提示：
> -p:保证目录名称存在，如果不存在则重新创建一个
> html: 映射容器中的静态资源目录
> logs: 日志文件目录
> conf: 配置文件目录
> conf.d: 配置文件子目录

```shell
mkdir -p /zhengqingya/soft/nginx/html /zhengqingya/soft/nginx/logs /zhengqingya/soft/nginx/conf /zhengqingya/soft/nginx/conf/conf.d
```

### 三、找到nginx镜像容器里面的配置文件、日志文件等位置 -> 目的：运行启动nginx时，将宿主机中的配置文件映射到容器中的配置文件（将nginx容器中的配置文件挂载到宿主机上） -> 即nginx启动后，使用的是宿主机中的配置

#### （1）以交互模式启动nginx容器,并在容器内执行/bin/bash命令 -> 进入到nginx容器中

```shell
docker run -it --name nginx -p 81:80 nginx:latest /bin/bash
```

#### （2）找到容器中需要的配置文件位置

①nginx.conf配置文件路径: /etc/nginx/nginx.conf

```shell
cd /etc/nginx/
ls -l 
```

②default.conf配置文件路径: /etc/nginx/conf.d/default.conf

> conf.d：为子目录，容器走完nginx.conf配置文件后，会走conf.d子目录下的配置文件

```shell
cd /etc/nginx/conf.d/ 
```

③存放静态资源文件夹html路径: /usr/share/nginx/html

```shell
cd /usr/share/nginx/ 
```

④日志文件路径: /var/log/nginx

```shell
cd /var/log/nginx
```

#### （3）最后按Ctrl+P+Q快捷键或输入exit命令退出容器终端~

```shell
 exit
```

### 四、拷贝容器内nginx默认配置文件到宿主机中，容器名或容器ID:执行docker ps命令查看

```shell
docker cp 161d51f2f6c0:/etc/nginx/nginx.conf /zhengqingya/soft/nginx_80/conf
docker cp 161d51f2f6c0:/etc/nginx/conf.d/default.conf /zhengqingya/soft/nginx_80/conf/conf.d
```

> 温馨小提示：
> 从容器中拷贝文件到宿主机中： docker cp 容器名或容器ID:容器中要拷贝的文件所在路径 要拷贝到宿主机中的对应路径
> 从宿主机中拷贝文件到容器中： docker cp 宿主机中要拷贝的文件路径 容器名或容器ID:要拷贝到容器中的对应路径

### 五、部署nginx

> 温馨小提示：
> 上面在容器中找配置文件以交互模式启动的nginx容器如果端口和下面要使用的端口冲突的话，需要停止相应进程、容器运行哦！！！
> 检查端口被哪个进程占用: netstat -lnp|grep 端口号
> 杀掉进程【ex:强制杀掉编号为10001的进程】:kill -9 10001
> 停止以启动的容器: docker stop nginx
> 删除容器: docker rm -f nginx
> 然后执行docker ps查看运行的容器，如果成功删除端口会冲突的容器，再部署，走下面的流程！！！

#### 执行如下命令部署 -> 启动运行nginx容器

```shell
docker run -d -p 81:80 --name nginx_80 -v /zhengqingya/soft/nginx_80/html:/usr/share/nginx/html -v /zhengqingya/soft/nginx_80/conf/nginx.conf:/etc/nginx/nginx.conf -v /zhengqingya/soft/nginx_80/conf/conf.d/default.conf:/etc/nginx/conf.d/default.conf -v /zhengqingya/soft/nginx_80/logs:/var/log/nginx nginx
-d: 以后台模式启动容器 -> 后台运行该容器
-p 81:80: 将nginx容器的 80 端口映射到宿主机的 81 端口       注:部分服务器需要手动去放行端口哦
--name nginx_80: 将容器命名为nginx_80
-v /zhengqingya/soft/nginx_80/html:/usr/share/nginx/html: 将宿主机中创建的 html 目录挂载到容器的 /usr/share/nginx/html 目录
```

### 六、测试访问

#### （1）到宿主机 /zhengqingya/soft/nginx/html 目录下创建 index.html 静态资源

```shell
cd /zhengqingya/soft/nginx/html

touch index.html # 创建文件

echo '<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>nginx容器运行中...</title>
</head>
<body>
    <h1> Hello World </h1>
    <p> If I were you. </p>
</body>
</html>' > index.html          # echo:如果没有这个文件则创建。如果有这个文件，那么新内容将会代替原来的内容。
```

> 这里也可以使用vi编辑器创建文件，命令如下：
> ```
> vi index.html  # 然后按i插入 ， 之后输入内容，按Esc退出编辑模式，切换到英文输入法按shift + : 再输入 wq 退出并保存
> 最后通过 cat index.html 命令查看文件内容
> ```

小编这里说下使用vi命令和echo命令去创建文件写入内容的区别： 在部署nginx运行时如果没有设置只读的情况下， （只读是挂载目录时后面加上:ro 如:-v /data/nginx/conf/nginx.conf:
/etc/nginx/nginx.conf:ro）

```shell
echo 命令 -> 修改内容,宿主机和容器配置文件都会改变
vi 命令 -> 修改内容,宿主机和容器配置互不影响
```

#### （2）浏览器输入 http://ip:端口/ 访问测试

---

# nginx配置反向代理 -> proxy_pass

nginx反向代理主要通过proxy_pass来配置，将你项目的开发机地址填写到proxy_pass后面，正常的格式为proxy_pass URL即可 vim
/zhengqingya/soft/nginx_test/conf/conf.d/default.conf

```
server {
    listen 80;
    location / {
        proxy_pass http://www.zhengqingya.com:81;  # 配置反向代理
    }
}
```

# upstream模块实现负载均衡 -> vim /zhengqingya/soft/nginx_test/conf/nginx.conf

```
upstream test { 
    server 66.22.111.250:80;
    server 66.22.111.250:81;
}
server {
    ....
    location  ~*^.+$ {         
        proxy_pass  http://test;  #请求转向test 定义的服务器列表         
    }
}
```

### 1、热备：如果你有2台服务器，当一台服务器发生事故时，才启用第二台服务器给提供服务。服务器处理请求的顺序：AAAAAA突然A挂啦，BBBBBBBBBBBBBB.....

```
upstream mysvr { 
    server 127.0.0.1:7878; 
    server 66.22.111.250:3333 backup;  #热备     
}
```

### 2、轮询：nginx默认就是轮询其权重都默认为1，服务器处理请求的顺序：ABABABABAB....

```
upstream mysvr { 
    server 127.0.0.1:7878;
    server 66.22.111.250:3333;       
}
```

### 3、加权轮询：跟据配置的权重的大小而分发给不同服务器不同数量的请求。如果不设置，则默认为1。下面服务器的请求顺序为：ABBABBABBABBABB....

```
upstream mysvr { 
    server 127.0.0.1:7878 weight=1;
    server 66.22.111.250:3333 weight=2;
}
```

### 4、ip_hash:nginx会让相同的客户端ip请求相同的服务器。

```
upstream mysvr { 
    server 127.0.0.1:7878; 
    server 66.22.111.250:3333;
    ip_hash;
}
```

举例:

```
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

http {
  	upstream demo { 
    	server 66.22.111.250:81;
    	server 66.22.111.250:9527;
    	# ip_hash; # ip_hash:nginx会让相同的客户端ip请求相同的服务器
	}
	server {
        listen 80;
    	server_name  www.wanghongmei.online;
        location / {
            proxy_pass http://demo; #请求转向demo 定义的服务器列表   
        }
    }
    # include /etc/nginx/conf.d/*.conf;
}

```

---

# 服务器nginx配置案例


```nginx

user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    # include /etc/nginx/conf.d/*.conf;
  
  	server {
        listen       80;
        server_name  www.zhengqingya.com;#域名名称

        #charset koi8-r;
        #access_log  /var/log/nginx/host.access.log  main;

        
    	
    	# start ---------------------------------------------------------------------------------------------
    
      	location / {
            root   /usr/share/nginx/html;
      		try_files $uri $uri/ @router;
            index  index.html index.htm;
       		#proxy_pass http://zhengqingya.gitee.io; # 代理的ip地址和端口号
            #proxy_connect_timeout 600; #代理的连接超时时间（单位：毫秒）
            #proxy_read_timeout 600; #代理的读取资源超时时间（单位：毫秒）
        } 

        location @router {
            rewrite ^.*$ /index.html last; # 拦截80端口后的所有请求地址到登录页面 -> 相当于后端的拦截器
        }

        location ^~ /api {  # ^~/api/表示匹配前缀为api的请求
            proxy_pass  http://www.zhengqingya.com:9528/api/;  # 注：proxy_pass的结尾有/， -> 效果：会在请求时将/api/*后面的路径直接拼接到后面
      
      		# proxy_set_header作用：设置发送到后端服务器(上面proxy_pass)的请求头值  
                # 【当Host设置为 $http_host 时，则不改变请求头的值;
                #   当Host设置为 $proxy_host 时，则会重新设置请求头中的Host信息;
      			#   当为$host变量时，它的值在请求包含Host请求头时为Host字段的值，在请求未携带Host请求头时为虚拟主机的主域名;
      			#   当为$host:$proxy_port时，即携带端口发送 ex: $host:8080 】
            proxy_set_header Host $host; 
      
      		proxy_set_header X-Real-IP $remote_addr; # 在web服务器端获得用户的真实ip 需配置条件①    【 $remote_addr值 = 用户ip 】
      		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;# 在web服务器端获得用户的真实ip 需配置条件②
            proxy_set_header REMOTE-HOST $remote_addr;
     		# proxy_set_header X-Forwarded-For $http_x_forwarded_for; # $http_x_forwarded_for变量 = X-Forwarded-For变量
        }
    
    	location ^~ /blog/ {
            proxy_pass  http://zhengqingya.gitee.io/blog/;  # ^~/blog/表示匹配前缀是blog的请求，proxy_pass的结尾有/， 则会把/blog/*后面的路径直接拼接到后面，即移除blog
      
            proxy_set_header Host $proxy_host; # 改变请求头值 -> 转发到码云才会成功
            proxy_set_header  X-Real-IP  $remote_addr;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-NginX-Proxy true;
        }
       
        # end ---------------------------------------------------------------------------------------------

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }

   }
}
```
