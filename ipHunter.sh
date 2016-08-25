#!/bin/bash
# author: nullPoint3r

echo '
 ______  _______   __    __                       __                         
|      \|       \ |  \  |  \                     |  \                        
 \$$$$$$| $$$$$$$\| $$  | $$ __    __  _______  _| $$_     ______    ______  
  | $$  | $$__/ $$| $$__| $$|  \  |  \|       \|   $$ \   /      \  /      \ 
  | $$  | $$    $$| $$    $$| $$  | $$| $$$$$$$\\$$$$$$  |  $$$$$$\|  $$$$$$\
  | $$  | $$$$$$$ | $$$$$$$$| $$  | $$| $$  | $$ | $$ __ | $$    $$| $$   \$$
 _| $$_ | $$      | $$  | $$| $$__/ $$| $$  | $$ | $$|  \| $$$$$$$$| $$      
|   $$ \| $$      | $$  | $$ \$$    $$| $$  | $$  \$$  $$ \$$     \| $$      
 \$$$$$$ \$$       \$$   \$$  \$$$$$$  \$$   \$$   \$$$$   \$$$$$$$ \$$      
                                                                             
                                                                             
                                                     by: nullPoint3r                        
'

# Regional Internet Registry URL 
AFRINIC=http://ftp.afrinic.net/stats/afrinic/delegated-afrinic-latest     #Africa Region
APNIC=http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest       #Asia/Pacific Region
ARIN=http://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest    #Canada, USA, and some Caribbean Islands
LACNIC=http://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest     #Latin America and some Caribbean Islands
RIPENCC=http://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest    #Europe, the Middle East, and Central Asia

#
CURRENT_DIR=`dirname $0`
DATA_DIR=$CURRENT_DIR/data
REGION_DIR=$CURRENT_DIR/region
REGISTRY=apnic
CC=CN

###############################################################################

usage() {
    echo -n "
 Usage: sh ipHunter [OPTION]... 

 Options:
    -c     Country code, see \"doc/List_fo_country_codes.doc\"
    -h     Display this help and exit
    -u     Upadte regional internet registry data
 
 Example: sh ipHunter -c CN 

"
    exit
}

updateData() {
    wget $AFRINIC -O $DATA_DIR/AFRINIC_latest.txt.tmp
    mv $DATA_DIR/AFRINIC_latest.txt.tmp $DATA_DIR/AFRINIC_latest.txt
    wget $APNIC -O $DATA_DIR/APNIC_latest.txt.tmp
    mv $DATA_DIR/APNIC_latest.txt.tmp $DATA_DIR/APNIC_latest.txt
    wget $ARIN -O $DATA_DIR/ARIN_latest.txt.tmp
    mv $DATA_DIR/ARIN_latest.txt.tmp $DATA_DIR/ARIN_latest.txt
    wget $LACNIC -O $DATA_DIR/LACNIC_latest.txt.tpm
    mv $DATA_DIR/LACNIC_latest.txt.tpm $DATA_DIR/LACNIC_latest.txt
    wget $RIPENCC -O $DATA_DIR/RIPENCC_latest.txt.tmp
    mv $DATA_DIR/RIPENCC_latest.txt.tmp $DATA_DIR/RIPENCC_latest.txt
    echo "All data is up-to-date!"
    exit
}

###############################################################################


# Get options
has_CC=false
while getopts "uhc:r:" arg
do
    case $arg in
        h ) usage ;;
        u ) updateData ;;
        c ) CC=$OPTARG; has_CC=true; echo $has_CC ;;
        ? ) 
            echo "
 [*] Uknown argument"
            usage ;;
    esac
done

if [ "$has_CC" = false ]; then 
    echo " [*] Missing country code, use '-c [Country code]' to indicate";
    usage
fi

# Init varibles
CC=`echo $CC | tr '[:lower:]' '[:upper:]'`
if grep $CC $REGION_DIR/RIPENCC.txt > /dev/null
then
    REGISTRY=ripencc
elif grep $CC $REGION_DIR/APNIC.txt > /dev/null
then
    REGISTRY=apnic
elif grep $CC $REGION_DIR/ARIN.txt > /dev/null
then
    REGISTRY=arin
elif grep $CC $REGION_DIR/LACNIC.txt > /dev/null
then
    REGISTRY=lacnic
elif grep $CC $REGION_DIR/AFRINIC.txt > /dev/null
then
    REGISTRY=afrinic
else
    echo "[*] Uknown country code!"
    echo "[*] Please check 'doc/List_fo_country_codes.doc'
    "
    exit
fi

# Get file
DATAFILE=$DATA_DIR/AFRINIC_latest.txt
if [[ ! -f $DATAFILE ]]; then
    echo "[*] File not found: $DATAFILE "
    echo "[*] Please update data with: 'sh ipHunter.sh -u'
    "
    exit
fi
case $REGISTRY in
        apnic ) DATAFILE=$DATA_DIR/AFRINIC_latest.txt ;;
        afrinic ) DATAFILE=$DATA_DIR/AFRINIC_latest.txt ;;
        arin ) DATAFILE=$DATA_DIR/AFRINIC_latest.txt ;;
        lacnic ) DATAFILE=$DATA_DIR/AFRINIC_latest.txt ;;
        ripencc ) DATAFILE=$DATA_DIR/AFRINIC_latest.txt ;;
        * ) echo "[*] Invalid registry"; exit ;;
esac

# filter CC IPs
grep "$REGISTRY|$CC|ipv4" $FILE | awk -F "|" '{print $4,$5}' > ip_tmp.txt

count=`cat ip_tmp.txt | wc -l`
line=1
while(($line<=$count));do
        IP=`sed -n ${line}p ip_tmp.txt | awk '{print $1}'`
        HOST=`sed -n ${line}p ip_tmp.txt | awk '{print $2}'`
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
        echo $IP/$NETMASK >> results.txt
        let line++
done
rm  ip_tmp.txt
