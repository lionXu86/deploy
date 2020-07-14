#!/bin/bash

#自定义全局变量

VERSION_ROOT=/data/code/version

WWW_ROOT=/data/web/www

NODE_LIST="192.168.0.111"

CTIME=$(date "+%Y-%m-%d")

#判断是否正确输入需要发布的版本

if [ -z "${git}" ];then

    echo -e "发布的版本号为空，请重新输入版本号后构建......"
    
    exit 1

else

#判断为发布操作时，执行以下代码块

if [ ${status} == "Deploy" ];then
        
#对节点列表进行发布代码

    for node in $NODE_LIST
    do
    
        # 使用rsync的方式将workspace的代码进行同步到目标主机，并进行软链接到站点根目录
        
        rsync -raz --delete --progress --exclude=cache --exclude=.git --exclude=.idea ${WORKSPACE}/ dengcom@$node:${VERSION_ROOT}/${git}/
    
        ssh dengcom@$node "rm -rf ${WWW_ROOT}"
    
        ssh dengcom@$node "ln -sv ${VERSION_ROOT}/${git} ${WWW_ROOT}"
        
        echo "发布成功......"
    done
fi


#判断为回滚操作时，执行以下代码块

if [ ${status} == "Rollback" ];then

    echo "准备回退......"
        

#对节点列表进行回退版本

for node in $NODE_LIST;do

    #判断目标主机是否存在回滚的版本
    
    ssh dengcom@$node "ls -ld ${VERSION_ROOT}/${git}"
    
    res=$(echo $?)
    
    if [ $res == 0 ];then
        
        ssh dengcom@$node "rm -rf ${WWW_ROOT}"

        ssh dengcom@$node "ln -sv ${VERSION_ROOT}/${git} ${WWW_ROOT}"
    
    else
    
        echo "回退版本："${git}"不存在"
        
        exit 2
        
    fi
    
done

echo "已成功回退到"${git}"版本......"    
