#!/bin/sh

function Usage {
  print "Usage: format.sh region"
}

function PrintDate {
  printf "%s" $1 | awk '{print substr($1,1,4) " " substr($1,5,2) " " substr($1,7,2) " " substr($1,9,2) " " substr($1,11,2)}' | read YEAR MONTH DAY HOUR MIN
  printf "%s-%s-%s:%s:%s" $YEAR $MONTH $DAY $HOUR $MIN
}

if [ $# -eq 0 ]
then
  Usage
  exit 1
fi

LINES=50
REGION=$1
TRANLOG=/cicsdump/ibmscript/logs/MonCicsTran/$REGION.out
TRADLOG=/cicsdump/ibmscript/logs/MonCicsTrad/$REGION.out

tail -$LINE $TRANLOG | awk -F\| '{print $4 " " $2 " " $3}' | while read DATE CURR QUEUE
do
  PrintDate $DATE
  printf " %-3s %-3s\n" $CURR $QUEUE
  ISNUM=`echo $CURR | grep "CICS" | wc -l`
  if [ $ISNUM -eq 1 ]
  then
    printf "\n"
    continue
  fi
  STARS=`expr $CURR / 10`
  printf "%-${STARS}s" "*" | sed 's/ /*/g'
done

tail -$LINE $TRADLOG | awk -F\| '{print $3 " " $2}' | while read DATE TRANS
do
  PrintDate $DATE
  printf " %-8s" $TRANS
  STARS=`expr $TRANS / 5000`
  printf "%-${STARS}s" "*" | sed 's/ /*/g'
done
