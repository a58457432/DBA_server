#!/bin/bash
# test_space

PATH=$PATH:/usr/local/bin
#get space 
db_user="root"
db_password="cgddnai!@#.hp"
db_socket='/tmp/mysql.sock'
source_dir=`mysql -u$db_user -p$db_password -S $db_socket -e "show variables like '%datadir%'" | grep -v V | awk '{print $2}'`
spc=(`du -sh $source_dir | cut -d "/" -f1 -`)

case $spc in
*G)
var1=`echo $spc| cut -d "G" -f1 -`
var2=`bc <<EOF
$var1*1024
EOF`
;;
*T)
var1=`echo $spc | cut -d "T" -f1 -`
var2=`bc <<EOF
$var1*1024*1024
EOF`
;;
*)
var1=`echo $spc | cut -d "M" -f1 -`
var2=$var1
esac

var3=`echo $var2 | awk '{print sprintf("%d", $0);}'`
echo "$var3"
