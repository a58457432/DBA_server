#!/bin/bash
# test_space

PATH=$PATH:/usr/local/bin

c0=(`df -h /data0/ | awk '{print $4}' | grep -v capacity | grep -v Avail`)
c1=(`df -h /data0/backup-data | awk '{print $4}' | grep -v capacity | grep -v Avail`)

if [[ -n $c1 ]];then
spc=$c1
else
spc=$c0
fi

#echo $spc

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
