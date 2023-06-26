# 在Docker Compose中定义通用配置并在多个地方进行引用可以通过使用YAML的锚点和别名功能来实现

锚点`common-config`，包含一组通用的配置项。然后在其他地方使用 `<<: *common-config` 来引用该通用配置。

通过这种方式，你可以在多个服务中轻松共享和重用通用配置块，提高了Docker Compose文件的可维护性和重用性。

eg：

```yml
version: '3'

# 定义通用配置
x-common-config: &common-config
  restart: unless-stopped
  volumes:
    - "./nginx/conf/nginx.conf:/etc/nginx/nginx.conf"
    - "./nginx/conf/conf.d/default.conf:/etc/nginx/conf.d/default.conf"
    - "./nginx/html:/usr/share/nginx/html"
    - "./nginx/log:/var/log/nginx"
  environment:
    TZ: Asia/Shanghai
    LANG: en_US.UTF-8

services:
  nginx-1:
    image: registry.cn-hangzhou.aliyuncs.com/zhengqing/nginx:1.21.1
    container_name: nginx-1
    <<: *common-config
    ports:
      - "81:80"

  nginx-2:
    image: registry.cn-hangzhou.aliyuncs.com/zhengqing/nginx:1.21.1
    container_name: nginx-2
    <<: *common-config
    ports:
      - "82:80"
```
