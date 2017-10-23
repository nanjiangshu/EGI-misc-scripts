#!/bin/bash

# get the information of all VMs on the endpoint
endpoint=https://prisma-cloud.ba.infn.it:8787/

rundir=`dirname $0`
basedir=$rundir/../
outpath=log/vminfo
if [ ! -d $outpath ];then
    mkdir -p $outpath
fi


credfile=$(find /tmp/ -maxdepth 1 -name "x509up_*" )
if [ "$credfile" == "" ];then
    echo "credfile not found at /tmp" >&2
    exit 1
fi

cd $basedir

vmlist=$(occi -e $endpoint -n x509 -x $credfile -X -a list -r compute)
if [ "$vmlist" != "" ];then
    echo "$vmlist" >  log/vmlist.txt
fi

for vm in $vmlist; do
    rcname=`basename $vm`
    outfile=$outpath/${rcname}.txt
    occi -e $endpoint -n x509 -x $credfile -X -a describe -r $vm > $outfile
    echo $outfile output
done

