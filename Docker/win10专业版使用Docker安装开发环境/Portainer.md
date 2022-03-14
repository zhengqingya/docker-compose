### 安装Docker可视化界面工具`Portainer`

```shell
# docker pull portainer/portainer
docker pull registry.cn-hangzhou.aliyuncs.com/zhengqing/portainer

# 创建文件夹 md或mkdir命令 【注意是反斜杠哦】
mkdir E:\zhengqingya\soft\soft-dev\Docker\data\portainer
# 创建文件
type nul>test.txt
# 创建文件并写入内容到文件
echo 'hello world' >test.txt

# 运行容器 
#         【 
#            -d: 后台运行容器，并返回容器ID
#            -p:本地（宿主机）端口：容器端口
#            --restart=always:设置启动Docker后自动运行容器     
#            --name:设置此容器的名字  
#            -v 本地目录:容器路径(注意：本地目录一定要存在  /e: 表示E盘下  ) 
#            portainer/portainer: portainer镜像
#          】
docker run -d -p 9000:9000 --restart=always --name portainer -v /e/zhengqingya/soft/soft-dev/Docker/data/portainer:/var/run/docker.sock portainer/portainer
docker run -d -p 9000:9000 --restart=always --name portainer -v /e/zhengqingya/soft/soft-dev/Docker/data/portainer:/var/run/docker.sock registry.cn-hangzhou.aliyuncs.com/zhengqing/portainer
```

然后访问 [http://127.0.0.1:9000/](http://127.0.0.1:9000/) 创建用户账号密码

![在这里插入图片描述](https://img-blog.csdnimg.cn/20191208150557715.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

打开docker设置
![在这里插入图片描述](https://img-blog.csdnimg.cn/20191208150723677.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

然后回到浏览器填写如下信息即可~
> local_zq ->  docker.for.win.localhost:2375

![在这里插入图片描述](https://img-blog.csdnimg.cn/20191208151003133.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20191208151031150.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
