# Dockerfile

- `ARG` 参数仅在图像构建期间可用
- `ENV` 变量在构建期间和容器中都可用
- `CMD` 在容器启动时执行，其中的`ARG`变量不再可用，若需要动态变量值应使用`ENV`

如果`CMD`中的`ENV`中又引用了另外一个`ENV`，比如说下面的案例；
那么`ENV JAVA_OPTS`的值将不能动态获取

```
ENV JAVA_OPTS
ENV RUN_CMD "java -jar ${JAVA_OPTS} app.jar"
CMD ["sh", "-c", "echo \"****** 运行命令：${RUN_CMD}\"   &   ${RUN_CMD}"]
```

让`JAVA_OPTS`变量正常动态获取则修改为如下；
或者使用`RUN_CMD`变量，废弃`JAVA_OPTS`变量

```
CMD ["sh", "-c", "echo \"****** 运行命令：java -jar ${JAVA_OPTS} app.jar\"   &   java -jar ${JAVA_OPTS} app.jar"]
```
