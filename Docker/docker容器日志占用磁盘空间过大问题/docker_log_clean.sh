#!/bin/bash

####################################
# @description 清理docker容器日志
# @params $? => 代表上一个命令执行后的退出状态: 0->成功,1->失败
# @example => sh docker_log_clean.sh
# @author zhengqingya
# @date 2021/9/29 17:30
####################################

# 在执行过程中若遇到使用了未定义的变量或命令返回值为非零，将直接报错退出
set -eu

echo "================== ↓↓↓↓↓↓ 清理docker容器日志 ↓↓↓↓↓↓ =================="

logs=$(find /var/lib/docker/containers/ -name '*-json.log*')

for log in $logs
do
    echo "clean log: $log"
    cat /dev/null > $log
done

echo "===================================================================="
