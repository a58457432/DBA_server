#!/bin/sh
# Author: HUPU.COM
# Last modified: 2015-08-17

vars_dir=`dirname $0`
source $vars_dir/pub_vars

## 检测 MySQL 服务是否能提供正常服务，如果不能则停止keepalived服务
#mysql_alive=`$mysqladmin_conn ping |grep -i 'mysqld is alive'|awk '{print $NF}'`
mysql_alive=`pgrep mysqld_safe`
[[ -z $mysql_alive ]] && $keepalived stop

## 检测vip是否在当前机器，如果不在则将 mysql 服务 read_only 参数置为真
keepalive_mos=`/sbin/ip addr |grep -o "$vip"`
if [[ $keepalive_mos != $vip ]];then
    check_read_only=`$mysql_conn -Nse "show variables like 'read_only'" |awk '{print $NF}'`
    if [[ $check_read_only == OFF || $check_read_only == 0 ]];then
        $vars_dir/change.read_only.role.sh 'read'
    fi
fi
