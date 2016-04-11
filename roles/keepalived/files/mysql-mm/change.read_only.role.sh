#!/bin/bash
# Author: HUPU.COM
# Last modified: 2015-08-17

vars_dir=`dirname $0`
source $vars_dir/pub_vars

function mysql_read_only () {
    $mysql_conn -e "flush logs; set global read_only=$1;"
    is_ok=$?
    for i in {1..5};do
        echo $i
        if [[ $is_ok != 0 ]];then
            sleep 2
            $mysql_conn -e "flush logs; set global read_only=$1;"
            is_ok=$?
        else
            break
        fi  
    done 
}

case $1 in
	read)
        mysql_read_only ON
        ;;
	write)
        mysql_read_only OFF
        ;;
	*)
        echo "UNKNOWN ERROR: Plase connect Admin."
        ;;
esac

