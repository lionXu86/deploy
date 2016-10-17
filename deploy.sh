#!/bash/sh
#author xqy

git_url='/tmp/test/store_shop'

#tmp file and dir
deplay_dir="/tmp/test1/"
source_zip=${deplay_dir}"source.zip"

#export dir
base_dir=$(cd `dirname $0`; pwd)

#git package
cd $git_url
git pull

#export
git archive master --format zip --output $source_zip
echo "\nexport and package complete!"

unzip -o $source_zip  -d $deplay_dir
echo "\nunzip complete!"

rm -f $source_zip

#*****************************************************************************************
cd $base_dir
#ansbile deploy
ansible-playbook deploy.yml


echo "\n\nDeploy Success!\n\n"




