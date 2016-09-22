#!/bin/bash
set -x

script_base=/tmp
script_name=autoDumpThread
script_home=$script_base/$script_name
script_log=$script_home/log
script_cfg=$script_home/cfg
mkdir -p $script_home
cpu_idle_std=10
dump_file_count_std=20
dt1=`date +%Y-%m-%d:%H:%M:%S`

function check_cpu ()
{
   cpu_idle=`vmstat 1 1| tail -1 | awk '{print $15}'`
   dump_file_count=`ls -l $script_home |wc -l`
   if [ $cpu_idle -lt $cpu_idle_std && $dump_file_count -lt $dump_file_count_std ]; then
      echo "$dt cpu idle $cpu_idle dump thread!"
      dump_thread
   else
      echo "$dt cpu idle $cpu_idle"
   fi
}

function dump_thread ()
{
   weblogic_pid=`ps -ef | grep "weblogic.Server" | grep -v grep | awk '{print $2}'`
   if [ $weblogic_pid != "" ]; then
       for i in 1 2 3
       do
         dt2=`date +%Y%m%d%H%M%S`
         jstack -l $weblogic_pid > $script_home/$dt-$weblogic_pid &
         pidstat -u -p $weblogic_pid -t 1 3 > $script_home/$dt-$weblogic_pid-cpu &
         sleep 5
       done
   fi
}

check_cpu
