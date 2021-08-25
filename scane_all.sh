#!/bin/bash
FILE=$1
while read line;do
    echo "$line"
done << $FILE