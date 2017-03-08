#!/bin/sh

# Usage: CheckJVM.sh gencon|thruput


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

function Print1 {
  printf "%-15s %-15s %+10s %+15s %+20s %+15s\n" $1 $2 $3 $4 $5 $6
}
function Pirnt2 {
  printf "%-15s %-15s %+15s %+15s %+25s $+25s\n" $1 $2 $3 $4 $5 $6
}

function Thruput {
  Print1 "HostName" "ServerName" "Timestamp" "Intervalms" "Free/Total(MB)" "FreePercent"
  ps -ef | grep java | grep websphere | grep -Ev "nodeagent|dmgr" | awk '{print $NF,$(NF-3)}' | sort | while read SERVER_NAME SERVER_DIR
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
    Print1 $HOSTNAME $SERVER_NAME $TIMESTAMP $INTERVAL "$FREEBYTES/$TOTALBYTES" $FREEPERCENT
  done
  if [ -e $TEMP_FILE ]
  then
    rm $TEMP_FILE
  fi
}

function Gencon {
  Print2 "HostName" "ServerName" "Timestamp" "Intervalms" "YoungFree/Total/Free%" "OldFree/Total/Free%"
  ps -ef | grep java | grep websphere | grep -Ev "nodeagent|dmgr" | awk '{print $NF,$(NF-3)' | sort | while read SERVER_NAME SERVER_DIR
  do
    SERVER_DIR=`echo $SERVER_DIR | sed 's/config//g'`
    GCLOG_DIR=$SERVER_DIR"logs/"$SERVER_NAME
    if [ -e "$GCLOG_DIR/native_stderr.log.001" ]
    then
      GCLOG_FILE=`ls -lrt $GCLOG_DIR/native_stderr.log.0* | tail -n 1 | awk '{print $9}'`
    else
      GCLOG_FILE="$GCLOG_DIR/native_stderr.log"
    fi
    tail -n 100 $GCLOG_FILE > $TEMP_FILE
    TIMESTAMP=`grep "<cycle-start"  $TEMP_FILE | tail -n 1 | awk -Ftimestamp=\" '{print $2}' | awk -F\" '{print $1}' | awk -FT '{print $2}'`
    INTERVAL=`grep "<cycle-start" $TEMP_FILE | tail -n 1 | awk -Fintervelms=\" '{print $2}' | awk -F\" '{print $1}'`

    YOUNGFREE=`grep "<mem type=\"nursery\"" $TEMP_FILE | tail -n 1 | awk -Ffree=\" '{print $2}' | awk -F\" '{print $1}'`
    YOUNGTOTAL=`grep "<mem type=\"nursery\"" $TEMP_FILE | tail -n 1 | awk -Ftotal=\" '{print $2}' | awk -F\" '{print $1}'`
    YOUNGPERCENT=`grep "<mem type=\"nursery\"" $TEMP_FILE | tail -n 1 | awk -Fpercent=\" '{print $2}' | awk -F\" '{print $1}'`

    OLDFREE=`grep "<mem type=\"tenure\"" $TEMP_FILE | tail -n 1 | awk -Ffree=\" '{print $2}' | awk -F\" '{print $1}'`
    OLDTOTAL=`grep "<mem type=\"tenure\"" $TEMP_FILE | tail -n 1 | awk -Ffree=\" '{print $2}' | awk -F\" '{print $1}'`
    OLDPERCENT=`grep "<mem type=\"tenure\"" $TEMP_FILE | tail -n 1 | awk -Ffree=\" '{print $2}' | awk -F\" '{print $1}'`
    
    YOUNGFREE=`expr $YOUNGFREE / 1048576`
    YOUNGTOTAL=`expr $YOUNGTOTAL / 1048576`
    YOUNGPERCENT=$YOUNGPERCENT"%"

    OLDFREE=`expr $OLDFREE / 1048576`
    OLDTOTAL=`expr $OLDTOTAL / 1048576`
    OLDPERCENT=$OLDPERCENT"%"
    
    Print2 $HOSTNAME $SERVER_NAME $TIMESTAMP $INTERVAL "$YOUNGFREE/$YOUNGTOTAL/$YOUNGPERCENT" "$OLDFREE/$OLDTOTAL/$OLDPERCENT"
  done
  if [ -f $TEMP_FILE ]
  then
    rm $TEMP_FILE
  fi
}

GC_POLICY=$1

if [ $GC_POLICY = "thruput" ]
then
  Thruput
elif [ $GC_POLICY = "gencon" ]
then
  Gencon
else
  exit 1
fi
