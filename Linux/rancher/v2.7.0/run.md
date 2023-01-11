### Rancher - 开源容器管理平台

```shell
# 运行
docker-compose -f docker-compose-rancher.yml -p rancher up -d
# 查看密码
docker logs rancher 2>&1 | grep "Bootstrap Password:"
# 2023/01/11 02:07:22 [INFO] Bootstrap Password: wgxxj2vksgfj89xkll2cwtf9b5gfjg9vcjpmwgnc5rzsvggxjl2bc9
```

访问地址：[`http://ip地址:20000`](http://www.zhengqingya.com:20000)
