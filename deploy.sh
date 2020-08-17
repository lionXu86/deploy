#!/bash/sh
#author xqy

#git dir
git_dir='/tmp/test/store_shop/'

#tmp file and dir
deplay_dir="/tmp/deploy/store_shop/"
source_zip=${deplay_dir}"source.zip"

mkdir -p $deplay_dir

#export dir
base_dir=$(cd `dirname $0`; pwd)

#git package
cd $git_dir
git pull

#export
git archive master --format zip --output $source_zip
echo "\nexport and package complete!"

unzip -o $source_zip  -d $deplay_dir
echo "\nunzip complete!"

rm -f $source_zip

rm -rf $deplay_dir

#*****************************************************************************************
cd $base_dir
#ansbile deploy
ansible-playbook deploy.yml -i ../hosts


echo "\n\nDeploy Success!\n\n"




