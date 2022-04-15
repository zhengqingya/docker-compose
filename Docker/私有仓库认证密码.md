### 认证私有仓库

```shell
# 认证阿里云
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
