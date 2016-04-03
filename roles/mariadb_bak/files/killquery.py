#!/usr/bin/env python
#

import MySQLdb
import os,sys,time
import subprocess,signal
from optparse import OptionParser

#source 


class dbhealther():
    
    def __init__(self, host, user, passwd, schema,port):
        self.host=host
        self.port=port
        self.user=user
        self.passwd=passwd
        self.schema=schema
        global cursor
        global db
        db=MySQLdb.connect(self.host,  self.user, self.passwd, self.schema,self.port,unix_socket='/tmp/mysql.sock')
        cursor=db.cursor()
         
    def chk_processlist(self):
        sstr="select * from processlist where user not in ('system user','root');"
        cursor.execute(sstr)
        data=cursor.fetchall()
        for i in data:
            print i
        db.close()

    
    def kill_sleep_query(self):
        cmd="/usr/bin/pt-kill    --victims  all     --match-command='Sleep'   --idle-time=30   --interval 5      -S /tmp/mysql.sock --host=%s --user=%s --password='%s'  --kill --daemonize" % (self.host, self.user, self.passwd)
        print cmd
        os.system(cmd)
    
    def kill_busy_query(self):
        cmd_busy="/usr/bin/pt-kill    --victims  all   --busy-time=10   --interval 5   -S  /tmp/mysql.sock  --user='%s' --password='%s' --host='%s'  --kill  --daemonize" % (self.user,self.passwd,self.host)
        print cmd_busy
        os.system(cmd_busy)
        
    def kill_match_info(self,sqltype):
        self.sqltype=str(sqltype)
        cmd_info="/usr/bin/pt-kill  --victims  all   --busy-time=10 --interval 5  --match-info='%s'   -S  /tmp/mysql.sock  --user='%s' --password='%s'  --host='%s' --kill  --daemonize" % (self.sqltype,self.user,self.passwd,self.host)
        print cmd_info
        os.system(cmd_info)

 
    def clean_PtTools(self):
        p = subprocess.Popen(['ps', '-A'], stdout=subprocess.PIPE)
        out, err = p.communicate()
        for line in out.splitlines():
            if 'perl' in line:
                pid = int(line.split(None, 1)[0])
                os.kill(pid, signal.SIGKILL)
        
def helps():
    parser = OptionParser(usage="usage: %prog [options] filename",
                          version="%prog 1.0")
    parser.add_option("-t", "--threads",
                      action="store_true",
                      dest="db_threads",
                      default="buys",
                      help="input -t sleep | -t busy & kill busy sleep threads")
    parser.add_option("-s", "--sql",
                      action="store_true",
                      dest="busy_threads",
                      default="bb",
                      help="input : select|update|insert|delete",)
    parser.add_option("-c", "--clean",
                      action="store_true",
                      dest="clean_threads",
                      default="cl",                                                                                                                                                                 
                      help="input: clean &  clean pt-threads",)
    (options, args) = parser.parse_args()

    if len(args) != 1:
        parser.error("wrong number of arguments")
    
    return args
#    print options
#    print args
#    print options.dest

def main():
    db_host='localhost'
    db_user='root'
    db_passwd='cgddnai!@#.hp'
    db_schema='information_schema'
    db_port=3230
    
    kthr=helps()
    kthr=''.join(kthr)
    dbper=dbhealther(db_host,db_user,db_passwd,db_schema,db_port)
    dbper.clean_PtTools()
    if str(kthr) == 'sleep':
        dbper.kill_sleep_query()
    elif str(kthr) == 'busy':
        dbper.kill_busy_query()
    elif str(kthr) == 'clean':
        dbper.clean_PtTools()
    else:
        dbper.kill_match_info(kthr)

if __name__ == "__main__":
    main()

