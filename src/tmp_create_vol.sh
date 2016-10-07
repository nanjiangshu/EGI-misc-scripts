#!/bin/bash
# a temporary script to create a new volume, 
rundir=`dirname $0`
basedir=$rundir/../
usage="
USAGE: $0 vol-name SIZE_IN_GB
"
vol_name=$1
size=$2

if [ "$vol_name" == "" -o "$size" == "" ];then
    echo "$usage"
    exit 1
fi

logpath=$basedir/log/createvol/
if [ ! -d $logpath ];then
    mkdir -p $logpath
fi
logfile=$logpath/${vm_name}.createvol.log

# get the information of all VMs on the endpoint
endpoint=https://prisma-cloud.ba.infn.it:8787/
credfile=$(find /tmp -maxdepth 1 -name "x509up_*" )
if [ "$credfile" == "" ];then
    echo "credfile not found at /tmp" >&2
    exit 1
fi

cd $basedir


# create a block storage
rtvalue=$(occi -e $endpoint --auth x509 --user-cred $credfile --voms -a create -r storage -t occi.storage.size="num($size)"  occi.core.title="$vol_name")

newid=
if [[ "$rtvalue" =~ "$endpoint" ]];then
    newid=$(basename $rtvalue)
    echo "StorageNode: $rtvalue" >> $logfile
    echo "StorageNode: $rtvalue"
else
    echo "$rtvalue"
fi
