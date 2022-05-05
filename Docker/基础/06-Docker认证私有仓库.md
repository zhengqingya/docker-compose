### 认证私有仓库

```shell
# 登陆镜像仓库
docker login
# ex:认证阿里云
docker login -u 用户名 -p 密码 registry.cn-hangzhou.aliyuncs.com
docker login --username=xxx registry.cn-hangzhou.aliyuncs.com
```

### 查看密码

`config.json` 会记录登录之后的用户名和密码，只是base64加密之后的密码。

```shell
# 查看密码
cat ~/.docker/config.json


# ex:
{
        "auths": {
                "ccr.ccs.tencentyun.com": {
                        "auth": "TMAxxx1Ng=="
                },
                "registry.cn-hangzhou.aliyuncs.com": {
                        "auth": "emhxxxnLg=="
                }
        }
}


# 解密
echo 'emhxxxnLg==' | base64 --decode
# username:password
```

### 移除认证凭证

```shell
# 移除阿里云认证
docker logout registry.cn-hangzhou.aliyuncs.com
```
