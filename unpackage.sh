#!/bin/sh

target="/usr/share/nginx/html"

base_dir=$(cd `dirname $0`; pwd)

cd $target

unzip -o ./lastest-version.zip -d $target

svn_del="./svndel.m"

if [ -f $svn_del ];then

	for i in `cat $svn_del`;do
		
		rm -rf "."$i;
			
	done;
	
	rm -rf $svn_del
fi;

rm -rf ./lastest-version.zip



echo "\n\n Complete Success!\n\n"





