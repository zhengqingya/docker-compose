### Docker 安装 Jenkins

```shell
# 拉取镜像
docker pull jenkins/jenkins:lts

# 创建一个jenkins目录 【注意是反斜杠哦】
mkdir E:\zhengqingya\soft\soft-dev\Docker\data\jenkins_home

# 启动一个jenkins容器      
docker run -d --name jenkins -p 8080:8080 --restart=always -v /e/zhengqingya/soft/soft-dev/Docker/data/jenkins_home:/home/jenkins_home jenkins/jenkins:lts
```

接下来的配置可参考：[https://zhengqing.blog.csdn.net/article/details/95232353](https://zhengqing.blog.csdn.net/article/details/95232353)

访问 `Jenkins` [http://127.0.0.1:8081](http://127.0.0.1:8081) ， 
提示需要到 `/var/jenkins_home/secrets/initialAdminPassword`中获取密码

![在这里插入图片描述](https://img-blog.csdnimg.cn/20191222172958288.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
然后我们可以进入容器中查看密码
![在这里插入图片描述](https://img-blog.csdnimg.cn/20191222173159904.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20191222173333931.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
然后就是安装插件了

> 这里建议选择第二个进行选择性安装

![在这里插入图片描述](https://img-blog.csdnimg.cn/20191222173434268.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
创建一个管理员
![在这里插入图片描述](https://img-blog.csdnimg.cn/201912221744071.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
`continue as admin` -> 进入Jenkins里面后可修改admin账号密码

#### 全局工具配置 [http://127.0.0.1:8081/configureTools/](http://127.0.0.1:8081/configureTools/)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20191222180641243.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20191222180613207.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

JDK配置 、Maven配置
![在这里插入图片描述](https://img-blog.csdnimg.cn/20191222181228491.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly96aGVuZ3FpbmcuYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

#### 插件安装  [http://127.0.0.1:8081/pluginManager/available](http://127.0.0.1:8081/pluginManager/available)

> 站点修改： http://mirror.xmission.com/jenkins/updates/update-center.json

1. `Pipeline`
2. `Blue Ocean`
3. `Discard Old Build` ：删除Jenkins旧的构建来释放磁盘空间
4. `Pipeline Maven Integration`
5. `Localization: Chinese (Simplified)`：中文插件

可参考：
[持续集成-Jenkins常用插件安装](https://www.cnblogs.com/zhanglianghhh/archive/2018/10/11/9770529.html)
[晒一晒Jenkins那些常用插件](https://www.jianshu.com/p/e0b7d377132a?from=timeline)

