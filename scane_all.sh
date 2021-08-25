#!/bin/bash
FILE=$1
Path=$2
echo -n SUDO Password: 
read -s password
echo
while read line;do
    echo "$line"
    mkdir $Path/$line
    sshpass -p "$password" sudo nmap -A -sS -Pn -p- $line -oN $Path/$line/nmap_out --min-rate=5000
done < $FILE
while read line;do
    if [ $(cat $Path/$line/nmap_out | grep '80/tcp[[:blank:]]*open' | wc -m) -gt 0 ];then 
        nikto -h $line -o $Path/$line/nikto_80_out -Format txt &
        dirb http://$line -o $Path/$line/dirb_80_out &
    fi 
done < $FILE
while read line;do
    if [ $(cat $Path/$line/nmap_out | grep '443/tcp[[:blank:]]*open' | wc -m) -gt 0 ];then 
        nikto -h $line -o $Path/$line/nikto_80_out -Format txt &
        dirb http://$line -r -o $Path/$line/dirb_80_out &
    fi 
done < $FILE
while read line;do
    if [ $(cat $Path/$line/nmap_out | grep '445/tcp[[:blank:]]*open' | wc -m) -gt 0 ];then 
        nmap --script=smb* -p445 $line -o $Path/$line/smb_scane_out &
    fi 
done < $FILE
while read line;do
    sshpass -p "$password" sudo nmap nmap -sU --top-ports 1000 $line -oN $Path/$line/nmap_top_udp_out --min-rate=5000
done < $FILE
