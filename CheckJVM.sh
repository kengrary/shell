#!/bin/sh

# for WASv7 not gencon

ENABLE=ON

SCRIPT_NAME=CheckJVM
BASE_DIR=/tmp
TEMP_DIR=$BASE_DIR/$SCRIPT_NAME
TEMP_FILE=$TEMP_DIR/temp.out
HOSTNAME=`hostname`


if [ -d $TEMP_DIR ]
then
  echo "" > /dev/null
else
  mkdir $TEMP_DIR
fi

function Print {
  printf "%-15s %-15s %+10s %+15s %+20s %+15s\n" $1 $2 $3 $4 $5 $6
}

if [ $ENABLE = "ON" ]
then
  Print "HostName" "ServerName" "Timestamp" "Intervalms" "Free/Total(MB)" "FreePercent"
  ps -ef | grep java | grep websphere | grep -Ev "nodeagent|dmgr" | awk '{print $NF,$(NF-3)}' | sort | while read $SERVER_NAME $SERVER_DIR
  do
    SERVER_DIR=`echo $SERVER_DIR | sed 's/config//g'`
    GCLOG_DIR=$SERVER_DIR"logs/"$SERVER_NAME
    if [ -e "$GCLOG_DIR/native_stderr.log.001" ]
    then
      GCLOG_FILE=`ls -ltr $GCLOG_DIR/native_stderr.log.0* | tail -n 1 | awk '{print $9}'`
    else
      GCLOG_FILE="$GCLOG_DIR/native_stderr.log"
    fi
    tail -n 100 $GCLOG_FILE > $TEMP_FILE
    TIMESTAMP=`grep "<af type=" $TEMP_FILE | tail -n 1 | awk -Ftimestamp=\" '{print $2}' | awk '{print $3}'`
    INTERVAL=`grep "<af type=" $TEMP_FILE | tail -n 1 | awk -Fintervalms=\" '{print $2}' | awk -F\" '{print $1}'`
    FREEBYTES=`grep "<tenured" $TEMP_FILE | tail -n 1 | awk -Ffreebytes=\" '{print $2}' | awk -F\" '{print $1}'`
    TOTALBYTES=`grep "<tenured" $TEMP_FILE | tail -n 1 | awk -Ftotalbytes=\" '{print $2}' | awk -F\" '{print $1}'`
    FREEPERCENT=`grep "<tenured" $TEMP_FILE | tail -n 1 | awk -Fpercent=\" '{print $2}' | awk -F\" '{print $1}'`
    FREEBYTES=`expr $FREEBYTES / 1048576`
    TOTALBYTES=`expr $TOTALBYTES / 1048576`
    FREEPERCENT=$FREEPERCENT"%"
    Print $HOSTNAME $SERVER_NAME $TIMESTAMP $INTERVAL "$FREEBYTES/$TOTALBYTES" $FREEPERCENT
  done
  if [ -e $TEMP_FILE ]
  then
    rm $TEMP_FILE
  fi
fi
