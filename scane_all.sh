#!/bin/bash
FILE=$1
Path=$2
echo -n SUDO Password: 
read -s password
echo
while read line;do
    echo "$line"
    mkdir $Path/$line
    sshpass -p "$password" sudo nmap -A -sS -Pn -p- $line -oN $Path/$line/nmap_out --min-rate=3000
done < $FILE
while read line;do
    if [ $(cat $Path/$line/nmap_out | grep "80/tcp open" | wc -m) -gt 0 ];then 
        nikto -h $line -o $Path/$line/nikto_out -Format txt &
    fi 
done < $FILE
while read line;do
    if [ $(cat $Path/$line/nmap_out | grep "80/tcp open" | wc -m) -gt 0 ];then 
        dirb http://$line -o $Path/$line/dirb_out &
    fi 
done < $FILE
