#!/bin/bash
# Author: HUPU.COM
# Last Update: 2015-09-15

vars_dir=`dirname $0`
source $vars_dir/pub_vars

mysqlbinlog='/usr/local/bin/mysqlbinlog'
cur_time=`date +%F' '%T`
skip_rep_error='set global sql_slave_skip_counter = 1'
mysql_cnf='/etc/my.cnf'
binlog_dir=`sed -n '/log[-|_]bin/{1,2p}' $mysql_cnf |awk '{print $3}'`
errorlog="$vars_dir/slave.err"
ssh='/usr/bin/ssh -o ConnectTimeout=1'
#跳出循环计数器
counter=0

while true
    do
    slave_status=`$mysql_conn -e 'show slave status\G' |grep -E " Master_Host| Master_Port| Master_Log_File| Read_Master_Log_Pos| Slave_IO_Running| Slave_SQL_Running| Last_Errno"`
    array_slave_status=($slave_status)

    # mysql replication 1062 error skip.
    last_error=`$mysql_conn -e "show slave status\G" |grep ' Last_Error' |sed 's/[ ][ ]*/ /g'`
    echo "$cur_time::$last_error" >> $errorlog
    #erro code, 1062: primary key duplicate. 1032: record not exists. 1050: table to exists. 1007: database to exists.
    #if [[ ${array_slave_status[13]} -eq 1062 || ${array_slave_status[13]} -eq 1050 || ${array_slave_status[13]} -eq 1007 ]]
    if [[ ${array_slave_status[13]} -eq 1062 ]]
        then
        $mysql_conn -e "stop slave;$skip_rep_error;start slave;"
    fi

    # mysql replication master crash recover data.
    local_vip=`/sbin/ip addr |grep -o "$vip"`
    if [[ $local_vip == $vip && $counter -eq 0 ]]
        then
        last_io_error=`$mysql_conn -e "show slave status\G" |grep ' Last_IO_Error' |sed 's/[ ][ ]*/ /g'`
        echo "$cur_time::$last_io_error" >> $errorlog
        $ssh -l root ${array_slave_status[1]} "$mysqlbinlog --start-position=${array_slave_status[7]} ${binlog_dir%/*}/${array_slave_status[5]}" |$mysql_conn
        chk_master_carash=`nc -w 1 -z ${array_slave_status[1]} ${array_slave_status[3]} |awk '{print $NF}' |sed 's/!//'`
        if [[ $chk_master_carash != succeeded ]]
            then
            binlogfile_preffix="${array_slave_status[5]%.*}"
            binlogfile_number=`echo "${array_slave_status[5]##*.} + 1" |bc`
            binlogfile_number_zero=`printf "%.6d" $binlogfile_number`
            new_binlogfile="$binlogfile_preffix.$binlogfile_number_zero"
            $mysql_conn -e "stop slave;CHANGE MASTER TO MASTER_LOG_FILE='"$new_binlogfile"',MASTER_LOG_POS=4;start slave;"
        fi
        let counter++
        sleep 0.3
        slave_last_errno=`$mysql_conn -e 'show slave status\G' |grep " Last_Errno"`
        [ $slave_last_errno -eq 0 || $slave_last_errno -ne 1062 ] && break
    fi

    [ ${array_slave_status[13]} -eq 0 || ${array_slave_status[13]} -ne 1062 ] && break
done
