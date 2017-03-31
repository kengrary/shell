#!bin/bash

DUMPFILE=$1
KEYWORD="ConTS_GetASWork|cicsas|ComSU_XPRecv"

if [[ $DUMPFILE == "" ]]
then
  DUMPFILE=`ls -lrt /cicsdump/script/logs/CollectCicsDump/*dumpthread* | tail -1 | awk '{print $NF}'`
fi

cat $DUMPFILE | awk 'NF>2 {print $2}' | awk -F[\(\)] '{++s[$1]} END {for(k in s) print k,s[k]}' | sort -rn -k 2 | grep -E "$KEYWORK"

