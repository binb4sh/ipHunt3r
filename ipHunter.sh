#!/bin/bash

# Get file
wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
FILE=delegated-apnic-latest

# filter CN ips
grep "apnic|CN|ipv4" $FILE | awk -F "|" '{print $4,$5}' > IP.txt

count=`cat IP.txt | wc -l`
line=1
while(($line<=$count));do
        IP=`sed -n ${line}p IP.txt | awk '{print $1}'`
        HOST=`sed -n ${line}p IP.txt | awk '{print $2}'`
        NETMASK=0
        case $HOST in
                256 ) NETMASK=24 ;;
                512 ) NETMASK=23 ;;
                1024 ) NETMASK=22 ;;
                2048 ) NETMASK=21 ;;
                4096 ) NETMASK=20 ;;
                8192 ) NETMASK=19 ;;
                16384 ) NETMASK=18 ;;
                32768 ) NETMASK=17 ;;
                65536 ) NETMASK=16 ;;
                131072 ) NETMASK=15 ;;
                262144 ) NETMASK=14 ;;
                524288 ) NETMASK=13 ;;
                1048576 ) NETMASK=12 ;;
                2097152 ) NETMASK=11 ;;
                4194304 ) NETMASK=10 ;;
                * ) echo "INVALID NUMBER" ;;
        esac
        echo $IP/$NETMASK
        echo $IP/$NETMASK >> IP.SH
        let line++
done
rm -rf IP.txt $FILE