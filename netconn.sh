#!/bin/bash

netstat -ant | grep -i est | awk '{++s[$5]} END {for(k in s) printf("%-25s%-6s\n", k, s[k])}' | sort -rn -k 2 | head -10
