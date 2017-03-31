#!/bin/bash

ENABLE=ON
SCRT_NAME=AutoCollectCicsDump
ROOT_DIR=/cicsdump
SCRT_DIR=$ROOT_DIR/script
WORK_DIR=$SCRT_DIR/crontab
LOG_DIR=$SCRT_DIR/logs/$SCRT_NAME
LOG_FILE=$LOG_DIR/$SCRT_NAME.log
HOSTNAME=`hostname`
TIME=`date +"%Y%m%d%H%M%S"`

CHECKCICS="/cicsdump/script/run/PROGRAM/checkcics"
ABEND="ECI_ERR_TRANSACTION_ABEND"
TIMEOUT="ECI_ERR_RESPONSE_TIMEOUT"
NOCICS="ECI_ERR_NO_CICS"
DIED="ECI_ERR_CICS_DIED"
REGION="DGBILL1"
COUNT_FILE=$LOG_DIR/count.out
COUNT_STD=2
CURR_STD=100

if [[ $ENABLE == "ON" ]]
then 
  echo
else
  exit 1
fi

if [ ! -d $LOG_DIR ]
then
  mkdir $LOG_DIR
fi

if [ ! -e $COUNT_FILE ]
then
  echo 0 > $COUNT_FILE
fi

COUNT=`cat $COUNT_FILE`

if [[ $OUTPUT == $NOCICS || $OUTPUT == $DIED ]]
then
  exit 1
fi

if [[ $OUTPUT == $ABEND || $OUTPUT == $TIMEOUT ]]
then
  if [ $COUNT -lt $COUNT_STD ]
  then
    COUNT=`expr $COUNT + 1`
	echo $COUNT > $COUNT_FILE
  fi
else
  echo $OUTPUT | awk -F\$ 'NF>1 {print $1,$2}' | read CURR QUEUE
  if [ $CURR -ge $CURR_STD ]
  then
    if [ $COUNT -lt $COUNT_STD ]
	then
	  COUNT=`expr $COUNT + 1`
	  echo $COUNT > $COUNT_FILE
	fi
  fi
fi

if [ $COUNT -ge $COUNT_STD ]
then
  CollectDump
  echo 0 > $COUNT_FILE
fi


