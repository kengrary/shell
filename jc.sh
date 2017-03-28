#!/bin/bash

LOG_DIR=/wasdump/script/logs/MonWasCPU

function AnalyzeJavaCore {
	DATE=$1            #yyyymmdd
    ls $LOG_DIR/$DATE | while read SERVER
	do
      OUTPUT_DIR=$LOG_DIR/$DATE/$SERVER
	  PID_FILE=$OUTPUT_DIR/*.out
	  JAVACORE=$OUTPUT_DIR/javacore*.txt
	  cat $PID_FILE | awk 'NR>3 {print $0}' | sort -rn +5 | head -10 | awk '{print $4,$6}' | while read THREAD_ID CPU_USAGE
	  do
	    if [ $CPU_USAGE -gt 10 ]
		then
		  NATIVE_THREAD_ID=`echo "obase=16;$THREAD_ID"|bc`
		  echo "NATIVE_THREAD_ID: $NATIVE_THREAD_ID CPU_USAGE: $CPU_USAGE"
		  LINE_NO=`grep -n $NATIVE_THREAD_ID $JAVACORE | awk -F\: '{print $1}'`
		  LINE_NO_1=`expr $LINE_NO - 3 + 200`
		  LINE_NO_2=`head -n $LINE_NO_1 $JAVACORE | tail -100 | grep -n "3XMTHREADINFO3\ *Native" | head -1 | awk -F\: '{print $1}'`
		  LINE_NO_HEAD=`expr $LINE_NO - 3 + $LINE_NO_2`
		  head -n $LINE_NO_HEAD $JAVACORE | tail -n $LINE_NO_2
		fi
      done
	done
}

AnalyzeJavaCore $1

