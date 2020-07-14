#!/bin/bash

#自定义全局常量

# 目标机版本目录
VERSION_ROOT=/data/demo/version

# 目标机的网站访问目录，软连接
WWW_ROOT=/data/demo/www

# 源项目的Git工作目录
WORKSPACE=/home/xqy/demo

# 目标机的列表
NODE_LIST="115.159.52.15"

# 目标机ssh端口
SSH_PORT="20521"

# 操作
action=$1

# 版本号
version=$2

#判断是否正确输入需要发布的版本

if [ -z "${version}" ]; then

    echo -e "发布的版本号为空，请重新输入版本号后构建"
    
    exit 1

fi

#判断为发布操作时，执行以下代码块

if [ ${action} = "deploy" ]; then
        
    #对节点列表进行发布代码

    for node in $NODE_LIST; do

        ssh root@$node -p${SSH_PORT} "mkdir -p ${VERSION_ROOT}/${version}/"

        # 使用rsync的方式将workspace的代码进行同步到目标主机，并进行软链接到站点根目录

        rsync -raz --delete --progress --exclude=cache --exclude=.git --exclude=.idea -e "ssh -p ${SSH_PORT}" ${WORKSPACE}/ root@$node:${VERSION_ROOT}/${version}/
    
        ssh root@$node -p${SSH_PORT} "rm -rf ${WWW_ROOT}"
    
        ssh root@$node -p${SSH_PORT} "ln -sv ${VERSION_ROOT}/${version} ${WWW_ROOT}"
        
        echo "发布成功"
    done
fi


#判断为回滚操作时，执行以下代码块

if [ ${action} = "rollback" ];then

    echo "准备回退..."
        
    #对节点列表进行回退版本

    for node in $NODE_LIST; do

        #判断目标主机是否存在回滚的版本
        
        ssh root@$node -p${SSH_PORT} "ls -ld ${VERSION_ROOT}/${version}"
        
        res=$(echo $?)
        
        if [ $res = 0 ];then
            
            ssh root@$node -p${SSH_PORT} "rm -rf ${WWW_ROOT}"

            ssh root@$node -p${SSH_PORT} "ln -sv ${VERSION_ROOT}/${version} ${WWW_ROOT}"
        
        else
        
            echo "回退版本："${version}"不存在"
            
            exit 2
            
        fi
        
    done

    echo "已成功回退到"${version}"版本" 
fi   
