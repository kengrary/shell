#!/bin/sh

##CheckMQ.sh

DEPTHTHRESHOLD=50

function Print {
  printf "%-30s\t%-20s\n" $1 $2
}

dspmq | awk -F[\(\)] '{print $2,$4}' | while read QMGR STATUS
do
  Print "Queue Manager" "Status"
  Print $QMGR $STATUS
  printf "\n"
  if [[ $STATUS == "Running" ]]
  then
    Print "Channel" "Status"
    echo "dis chs(*) where (STATUS eq RETRYING)" | runmqsc $QMGR | grep CHANNEL | awk -F[\(\)] '{print $2}' | while read CHL
    do
      Print $CHL "RETRYING"
    done
    printf "\n"
    echo "dis ql(*) curdepth where(curdepth gt $DEPTHTHRESHOLD)" | runmqsc $QMGR | grep -E "QUEUE|CURDEPTH" | awk -F[\(\)] '{print $1,$2}' | while read QUEUE DEPTH
    do
      if [[ $QUEUE == "QUEUE" ]]
      then
        printf "%-30s\t" $DEPTH
      else
        printf "%-20s\n" $DEPTH
      fi
    done
  fi
  printf "\n"
done
