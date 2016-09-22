#!/bin/bash
set -x
#设置脚本运行目录，默认是/tmp，可根据实际情况修改script_home变量
script_base=/tmp
script_name=checkWls
script_home=$script_base/$script_name
script_log=$script_home/log
#设置包含weblogic服务器相关信息的配置文件路径，可以支持一台服务器多个weblogic服务
script_cfg=$script_home/cfg
mkdir -p $script_home
if [ !-f $script_cfg ]; then
 echo "[错误]请先配置cfg文件。"
 exit 1

#设置检查weblogic服务的超时
check_timeout=2
#设置当前日期时间
dt=`date +%Y-%m-%d:%H:%M:%S`

function check()
{
  start=$(date +%s.%N) 
  curl http://$2:$3/$4 --connect-timeout $check_timeout > $script_home/check.out 2> $script_home/error.out
  rc=$?
  end=$(date +%s.%N)
  t="$(getTiming $start $end)"
  if [ $rc == 0 ]; then
      check_result=`grep $5 $script_home/check.out | wc -l`
          if [ $check_result -ge 1 ]; then
           write $2:$3 $1 $4 "OK" $t"ms"
          else
           write $2:$3 $1 $4 "WARNING" $t"ms"
          fi
   else
      write $2:$3 $1 $4 "TIMEOUT" "0"
   fi
}
function header()
{
  write IP SERVER URL CHECK TIME
}
function write()
{
  printf "%-20s%-12s%-20s%-10s%-10s\n" $1 $2 $3 $4 $5 
}
function getTiming() {  
    start=$1  
    end=$2  
     
    start_s=$(echo $start | cut -d '.' -f 1)  
    start_ns=$(echo $start | cut -d '.' -f 2)  
    end_s=$(echo $end | cut -d '.' -f 1)  
    end_ns=$(echo $end | cut -d '.' -f 2)  
  
  
# for debug..  
#   echo $start  
#   echo $end  
    time=$(( ( 10#$end_s - 10#$start_s ) * 1000 + ( 10#$end_ns / 1000000 - 10#$start_ns / 1000000 ) ))  
    echo $time 
}  

header
#读取配置文件中的weblogic服务相关信息，然后对每一个服务进行检查
cat $script_cfg | grep -v "^#" |  awk -F\| '{print $1 " " $2 " " $3 " " $4 " " $5}' | while read wls_name wls_ip wls_port
do
 check $wls_name $wls_ip $wls_port $wls_url $key_word
done
