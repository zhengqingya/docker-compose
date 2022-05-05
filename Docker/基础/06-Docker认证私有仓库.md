### 认证私有仓库

```shell
# 认证
docker login -u 用户名 -p 密码 私有仓库地址
# ex:认证阿里云
# docker login -u xxx registry.cn-hangzhou.aliyuncs.com
# 认证harbor私服
docker login -u admin -p Harbor12345 harbor.zhengqingya.com:11000
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
                },
                "harbor.zhengqingya.com:11000": {
                        "auth": "YWRtaW46SGFyYm9yMTIzNDU="
                }
        }
}


# 解密
echo 'YWRtaW46SGFyYm9yMTIzNDU=' | base64 --decode
# username:password
```

### 移除认证凭证

```shell
# 移除认证
docker logout 私有仓库地址
# ex:移除阿里云认证
docker logout registry.cn-hangzhou.aliyuncs.com
```
