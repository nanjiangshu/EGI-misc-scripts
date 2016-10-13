#!/bin/bash

# Filename:  list_vm.sh
# Description: list the virtual machines on FedCloud
# Author: Nanjiang Shu (nanjiang.shu@scilifelab.se)

progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""` 
usage="
Usage:  $progname -e ENDPOINT [-short]
Options:
  -e       STR      Set endpoint, short name or full name
                    valid short names: TR, IT, FR
  -short            Do not list the detailed content of instances
  -h, --help        Print this help message and exit

Created 2016-09-22, updated 2016-10-13, Nanjiang Shu

Examples:
    $progname -e IT
"
PrintHelp(){ #{{{
    echo "$usage"
}
#}}}
ListVM(){ #{{{
    cmd="occi --endpoint $endpoint --auth x509 --user-cred $credfile --voms --action list --resource compute"
    echo "command: $cmd"
    echo
    eval "$cmd"
} 
#}}}
ListVM_detailed(){ #{{{
    cmd="occi --endpoint $endpoint --auth x509 --user-cred $credfile --voms --action list --resource compute"
    echo "command: $cmd"
    echo
    vmlist=$($cmd)
    for vm in $vmlist; do
        cmd="occi --endpoint $endpoint --auth x509 --user-cred $credfile --voms --action describe --resource $vm"
        info=$($cmd)
        title=$(echo "$info" | grep "^occi.core.title" | awk '{print $3}')
        cpu=$(echo "$info" | grep "^occi.compute.cores" | awk '{print $3}')
        memory=$(echo "$info" | grep "^occi.compute.memory" | awk '{print $3}')
        publicip=$(echo "$info" | grep "occi.networkinterface.address" | awk '{print $3}')
        echo -e "\n$vm"
        echo -e "\tTitle: $title"
        echo -e "\tCPU: $cpu"
        echo -e "\tRAM: $memory"
        echo -e "\tPublicIP: $publicip"
    done
} 
#}}}

if [ $# -le 1 ]; then
    PrintHelp
    exit
fi

isQuiet=0
endpoint=
isShowDetailedInfo=1

isNonOptionArg=0
while [ "$1" != "" ]; do
    if [ $isNonOptionArg -eq 1 ]; then 
       echo Error! Wrong argument: $1 >&2; exit
        isNonOptionArg=0
    elif [ "$1" == "--" ]; then
        isNonOptionArg=true
    elif [ "${1:0:1}" == "-" ]; then
        case $1 in
            -h | --help) PrintHelp; exit;;
            -e|--e) endpoint=$2;shift;;
            -short|--short) isShowDetailedInfo=0;;
            -q|-quiet|--quiet) isQuiet=1;;
            -*) echo Error! Wrong argument: $1 >&2; exit;;
        esac
    else
       echo Error! Wrong argument: $1 >&2; exit
    fi
    shift
done

credfile=$(find /tmp -maxdepth 1 -name "x509up_*" )
if [ "$credfile" == "" ];then
    echo "credfile not found at /tmp" >&2
    exit 1
fi



if [[ ! "$endpoint" =~ "^http" ]] ;then
    case $endpoint in 
        TR|tr) endpoint=http://fcctrl.ulakbim.gov.tr:8787/occi1.1;;
        IT|it) endpoint=http://cloud.recas.ba.infn.it:8787/occi;;
        FR|fr) endpoint=https://sbgcloud.in2p3.fr:8787/occi1.1;;
        *) echo "unrecognized endpoint=$endpoint; exit" >&2;;
    esac
fi

if [ $isShowDetailedInfo -eq 0 ];then
    ListVM
else
    ListVM_detailed
fi

