#!/bash/sh
#author xqy

#export dir
base_dir=$(cd `dirname $0`; pwd)

#*****************************************************************************************
cd $base_dir

svn_file="./svn.txt"
if [ -s $svn_file ];
then
	svn_path=`cat $svn_file`
else
	exit 0
fi

version_file="./version.txt"
if [ -f $version_file ];then
        begin_version=`cat $version_file`
else
        begin_version=0
fi

end_version=`svn info $svn_path  | grep Revision: | awk   '{print $2}'`

if [ $begin_version = $end_version ]
then
	echo "[warn] svn version is lastest, nothing to do!"
	exit 0
fi


base_path=$base_dir"/"$begin_version"-"$end_version"/"

mkdir -p $base_path

version=$base_path"version/"

mkdir -p $version

#delete file log file
delete_log="svndel.m"


#export add,commit file
for i in `svn diff -r $begin_version:$end_version   --summarize $svn_path | grep '^[AM]' | sed 's:^[AM]\s*::g'`;do
	
	str1=`echo $i | sed 's#\.#!1!#g' | sed 's#\/#!2!#g' | sed 's#\:#!3!#g'`;
	str2=`echo $svn_path | sed 's#\.#!1!#g' | sed 's#\/#!2!#g' | sed 's#\:#!3!#g'`;
	
	str3=`echo $str1 | sed 's:'$str2'::g'`;	
	
	str4=`echo $str3 | sed 's/!1!/\./g' | sed 's/!2!/\//g' | sed 's/!3!/\:/g'`

	all_path=`echo $str4`;

	parent_path=`dirname $all_path`;
	
	dir=${version}${parent_path};
	if [ ! -d $dir ];then	
	   mkdir -p $dir;
	fi;
	
	svn export --force  ${svn_path}${all_path} ${version}${all_path};

done

#record delete file, this is important,ye~~~
for i in `svn diff -r $begin_version:$end_version   --summarize $svn_path | grep '^[D]' | sed 's:^[D]\s*::g'`;do
	
	str1=`echo $i | sed 's#\.#!1!#g' | sed 's#\/#!2!#g' | sed 's#\:#!3!#g'`;
        str2=`echo $svn_path | sed 's#\.#!1!#g' | sed 's#\/#!2!#g' | sed 's#\:#!3!#g'`;

        str3=`echo $str1 | sed 's:'$str2'::g'`;

        str4=`echo $str3 | sed 's/!1!/\./g' | sed 's/!2!/\//g' | sed 's/!3!/\:/g'`

        all_path=`echo $str4`;

	echo $all_path >> ${version}${delete_log}

done

#*****************************************************************************************
#delete ignore config file
cd $base_dir
for i in `cat ./ignore`;do
	
	if [ -f ${version}${i} ];then
		echo "[info] delete igone file: "${version}${i}
		rm -rf ${version}${i}
	fi;
	
done

#******************************************************************************************
cd ${version}
time=$(date +%Y%m%d%H%M%S)
svn diff -r $begin_version:$end_version   --summarize $svn_path > ${base_path}${time}.txt

#dabao
#zip -r ${base_path}${begin_version}'-'${end_version}".zip" "./"
if [ `ls ./`=''  ];then
	echo "[warn] no file need update"

	#rollback
	cd $base_dir
	rm -rf $base_path
		
	exit 0
fi;

echo "\npackage....\n"
zip 	-r ${base_path}"version.zip" "./"

cp  ${base_path}"version.zip" ../../lastest-version.zip

echo "\n[info] make zip file finished!\n"

#******************************************************************************************
cd $base_dir

echo $end_version > $version_file

echo "\n[info] update version file finished!\n"

echo '\n\n[info] Package Complete!\n'



#ansbile deploy
ansible-playbook deploy.yml


echo "\n\nDeploy Success!\n\n"






