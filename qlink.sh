#!/bin/sh



LOCALINI=host.ini # need modify

# INIFILE FORMAT:
# TYPE SYSTEM GROUP MWTYPE HOSTNAME IPADDRESS RTYPE NULL NULL NOTE

GROUP=$1

COUNT=`cat $LOCALINI | grep NG | grep -w $GROUP | grep -v "^#" | wc -l`

function ListHost {
  j=1
  printf "%-6s %-10s %-18s %-25s %-6s\n" "No." "MW" "HOST" "IP" "NOTE"
  cat $LOCALINI | grep NG | grep -w $GROUP | grep -v "^#" | awk '{print $4,$5,$6,$10}' | while read MW HOSTNAME IPADDR NOTE
  do
    printf "%-6s %10s %-18s %-25s %-62\n" $ii $MW $HOSNAME $IPADDR $NOTE
    j=`expr $j + 1`
  done
}

function GoToHost {
  i=1
  cat $LOCALINI | grep NG | grep -w $GROUP | grep -v "^#" | awk '{print $4,$5,$6,$7}' | while read MW HOSTNAME IPADDR RTYPE
  do 
    if [[ $NUM == $i ]]
    then
      break
    else
      i=`expr $i + 1`
    fi
  done

  RSHFLAG=`echo $RTYPE | grep rsh | wc -l`
  if [ $RSHFLAG -eq 1 ]
  then
    rsh $IPADDR
  else
    ssh $IPADDR
  fi
}


ListHost
while read NUM?"Please enter the No. or [q]uit:"
do
  TMPVAR=`echo $NUM | grep -iE '[1-9]*|q|quit' | wc -l`
  if [ $TMPVAR -eq 1 ]
  then
    if [[ $NUM == "q" ]] || [[ $NUM == "quit" ]]
    then
      exit 0
    elf [ $NUM -le $LINE ]
    then
      break
    else
      continue
    fi
  fi
done
GoToHost $NUM
