#!/bin/bash

ss -ant | awk 'NR>1 {++s[$1]} END {for(k in s) print k,s[k]}'
