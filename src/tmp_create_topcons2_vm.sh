#!/bin/bash

# a temporary script to create a new VM for installing topcons2, no topcons2 image

rundir=$(dirname $0)
basedir=$rundir/../


usage="
USAGE: $0 vm-name
"
vm_name=$1

if [ "$vm_name" == "" ];then
    echo "$usage"
    exit 1
fi

logpath=$basedir/log/createvm/
if [ ! -d $logpath ];then
    mkdir -p $logpath
fi
logfile=$logpath/${vm_name}.createvm.log

# get the information of all VMs on the endpoint
endpoint=https://prisma-cloud.ba.infn.it:8787/
credfile=$(find /tmp -maxdepth 1 -name "x509up_*" )
if [ "$credfile" == "" ];then
    echo "credfile not found at /tmp" >&2
    exit 1
fi

rundir=`dirname $0`
basedir=$rundir/../
cd $basedir

rtvalue=$(occi -e $endpoint --auth x509 --user-cred $credfile --voms -a create -r compute --mixin os_tpl#d8d0788a-b1e5-4489-9934-2f20c6ef9b33 --mixin resource_tpl#16cpu-32gb-10dsk --attribute occi.core.title="nj-topcons2-t1" --context user_data="file://$PWD/new.tmpfedcloud.login")

newid=
if [[ "$rtvalue" =~ "$endpoint" ]];then
    newid=$(basename $rtvalue)
    echo "ComputeNode: $rtvalue"
    echo "ComputeNode: $rtvalue" >> $logfile
    # describe
    description=$(occi -e $endpoint --auth x509 --user-cred $credfile --voms -a describe --resource $rtvalue)
    echo "$description" >> $logfile
fi

