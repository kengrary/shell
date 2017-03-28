#!/bin/bash

SCRT_NAME=MonWasCPU
ROOT_DIR=/wasdump
SCRT_DIR=$ROOT_DIR/script
WORK_DIR=$SCRT_DIR/crontab
LOG_DIR=$SCRT_DIR/logs/$SCRT_NAME
TIME=`date +"%Y-%m-%d %H:%M:%S"`
DATE=`date +"%Y%m%d"`
IDLE=3

if [ ! -d $LOG_DIR ]
then
   mkdir $LOG_DIR
fi

if [ ! -f $LOG_DIR/count.out ]
then
   touch $LOG_DIR/count.out
fi

vmstat 1 5 | tail -1 > $LOG_DIR/vmstat.out
IDLE_CPU=`awk '{print $(NF-1)}' $LOG_DIR/vmstat.out`
#echo IDLE_CPU
COUNT=`cat $LOG_DIR/count.out`
if [ $IDLE_CPU -lt $IDLE ]
then
  if [ -n $COUNT ]
  then
    if [ $COUNT -eq 2 ]
    then
      ps -ef | grep java | grep websphere | grep -Ev "nodeagent|dmgr" | awk '{print $2,$NF}' | while read PID SERVER
	  do
	    OUTPUT_DIR=$LOG_DIR/$DATE/$SERVER
	    if [ ! -d $OUTPUT_DIR ]
	    then
	      mkdir -p $OUTPUT_DIR
	    fi
	    if [ -e $OUTPUT_DIR/javacore* ]
	    then
	      CORE_COUNT=`ls -l $OUTPUT_DIR/javacore* | wc -l`
	    else
	      CORE_COUNT=0
        fi
	    if [ $CORE_COUNT -lt 5 ]
	    then
	      echo $TIME >> $OUTPUT_DIR/$PID.out
		  kill -3 $PID && ps -mT $PID -o THREAD >> $OUTPUT_DIR/$PID.out
		  >$LOGDIR/count.out
		  sleep 10
		  JAVACORE=`ls -l /wasdump/heapdump/$SERVER/javacore* | tail -1 | awk '{print $9}'`
		  cp $JAVACORE $OUTPUT_DIR
	    fi
	   done
   if [ $COUNT -lt 2 ]
   then
     COUNT=`expr $COUNT + 1`
	 echo $COUNT > $LOG_DIR/count.out
   fi
  else
    echo 1 > $LOG_DIR/count.out
  fi
fi
