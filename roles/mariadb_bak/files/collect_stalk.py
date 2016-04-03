#!/usr/bin/env python
#

import MySQLdb
import os


#source 
db_host='127.0.0.1'
db_user='root'
db_passwd='cgddnai!@#.hp'
dir='/data0/db-stalk'




def db_threads():
    db=MySQLdb.connect(db_host,db_user,db_passwd)
    cursor=db.cursor()
    cursor.execute("show global status like 'Threads_connected';")
    data=cursor.fetchone()
    val=data[1]
    return val
    db.close()
 
def mkdir(path):
    path=path.strip()
    path=path.rstrip("\\")
    isExists=os.path.exists(path)
    if not isExists:
        print path+'create dir sucess' 
        os.makedirs(path)
        return True
    else:
        print path+'dir has been created'
        return False  


def start_stalk():
    thx=db_threads()
    if int(thx) > 1000: 
        connect_command="/usr/bin/pt-stalk --collect-tcpdump --function status --variable Threads_connected --threshold 1000 --daemonize --user={0} --password={1} --dest={2} --run-time=60".format(db_user, db_passwd, dir)
        os.system(connect_command)
        print "thx > 1000"
    else:
        print "thx < 1000" 


def kill_thx():
    kthx=db_threads()
    if int(kthx) < 700:
        lines = os.popen('ps -ef|grep pt-stalk|grep -vi grep')
        for line in lines:
            vars=line.split()
            pid=vars[1]
            proc = vars[8]

        out=os.system('kill '+pid)
        if out==0:
            print('sucess kill '+pid+' '+proc)
        else:
            print('fail kill'+pid+' '+proc)


#def clean_stalk():
#    clear_command="find {0} -type f -mtime +7 -exec rm -f {} \;".format(dir)
#    print clear_command
#    os.system(clear_command)
    
if __name__ == "__main__":
    mkdir(dir)
    start_stalk()
    kill_thx() 
