# docker-compose自动识别主机IP

如果您在 Windows 或 Mac 上运行 Docker，可以使用特殊的 DNS 名称来访问主机，即 `host.docker.internal`。

eg: 

```yml
version: '3'

services:
  kafka:
    image: registry.cn-hangzhou.aliyuncs.com/zhengqing/kafka:3.4.1
    container_name: kafka
    environment:
      ALLOW_PLAINTEXT_LISTENER: yes
      KAFKA_CFG_ZOOKEEPER_CONNECT: zookepper:2181                        
      KAFKA_CFG_ADVERTISED_LISTENERS: PLAINTEXT://host.docker.internal:9092
    ports: 
      - "9092:9092"
```
