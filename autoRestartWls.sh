#!/bin/bash
#set -x

#设置脚本运行目录，默认是/tmp，可根据实际情况修改script_home变量
script_base=/tmp
script_name=autoRestartWls
script_home=$script_base/$script_name
script_log=$script_home/log
#设置包含weblogic服务器相关信息的配置文件路径，可以支持一台服务器多个weblogic服务
script_cfg=$script_home/cfg
mkdir -p $script_home


#设置weblogic服务器启动脚本
wls_start="/etc/init.d/weblogic start"
#设置检查weblogic服务的url
check_url=bpm/login
#设置检查weblogic服务的超时
check_timeout=3
#设置检查weblogic服务的关键字，即url返回的结果中必须包含的关键字
key_word=PSBC
#设置当前日期时间
dt=`date +%Y-%m-%d:%H:%M:%S`


#检查weblogic服务的方法，通过curl访问weblogic上的应用，根据返回的报文和定义的关键字判断服务是否正常
function check()
{
  curl http://$2:$3/$4 --connect-timeout $check_timeout > $script_home/check.out 2> $script_home/error.out
  if [ $? == 0 ]; then
      check_result=`grep $5 $script_home/check.out | wc -l`
          if [ $check_result -ge 1 ]; then
                   #服务正常，日志中记录为OK
           write $dt $2:$3 $1 "OK"
          else
                   #服务有返回，但不符合定义的关键字，可能是url或者关键字出现了变化
           wirte $dt $2:$3 $1 "WARNING"
          fi
   else
      #服务在超时内没有返回，判定为服务异常，调用重启方法
      write $dt $2:$3 $1 "ERR! RESTART"
      restart $1 $3
   fi
}
function restart()
{
  #重启前，判断weblogic服务器的pid，如果pid存在，则kill掉
  wls_pid=`ps -ef | grep $1 | grep -v grep | awk '{print $2}'`
  if [ "$wls_pid" != "" ]; then
      #kill -9 wls_pid
      sleep 1
  fi
  #kill掉进程后，再判断5次weblogic服务的端口是否释放
  for i in 1 2 3 4 5
  do
    wls_check_port=`netstat -an | grep $2 | wc -l`
    if [ $wls_check_port -eq 0 ];then
        break
    else
        sleep 1
    fi
  done
  echo restart!
  #调用重启脚本
  #$wls_start
}
function write()
{
  echo $1 $2 $3 $4 >> $script_log
}

#读取配置文件中的weblogic服务相关信息，然后对每一个服务进行检查
cat $script_cfg | grep -v "^#" |  awk -F\| '{print $1 " " $2 " " $3 " " $4 " " $5}' | while read wls_name wls_ip wls_port
do
 check $wls_name $wls_ip $wls_port $wls_url $key_word
 sleep 5
done