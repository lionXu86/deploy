### 项目发布和回滚脚本
* deploy.sh和deploy.yml是在发布机做打包，然后利用ssh和ansible发布目标机器
* deploy2.sh在发布机上进行操作，git pull和同步操作，以及实现回滚操作
