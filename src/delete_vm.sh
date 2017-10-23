#!/bin/bash

# Filename: delete_vm.sh
# Description: delete the virtual machines on FedCloud
# Author: Nanjiang Shu (nanjiang.shu@scilifelab.se)

progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""` 
usage="
Usage:  $progname VM [VM...] [-l LISTFILE]
Options:
  -e       STR      Set endpoint, short name or full name
                    valid short names: TR, IT, FR
  -l       FILE     Set the vmListFile, one filename per line
  -q                Quiet mode
  -h, --help        Print this help message and exit

Created 2015-03-31, updated 2016-09-12, Nanjiang Shu

Examples:
    $progname -e FR 188892c8-a6f6-445a-b2fe-0c5d267fe2ac
"
PrintHelp(){ #{{{
    echo "$usage"
}
#}}}
DeleteVM(){ #{{{
    local vm=$1
    local full_vm_name=
    if [[  "$vm" =~ "$endpoint" ]];then
        full_vm_name=$vm
    else
        full_vm_name=$endpoint/compute/$vm
    fi
    cmd="occi --endpoint $endpoint --auth x509 --user-cred $credfile --voms --action delete --resource $full_vm_name"
    echo "$cmd"
    eval "$cmd"
} 
#}}}

if [ $# -lt 1 ]; then
    PrintHelp
    exit
fi

isQuiet=0
vmListFile=
vmList=()
endpoint=

isNonOptionArg=0
while [ "$1" != "" ]; do
    if [ $isNonOptionArg -eq 1 ]; then 
        vmList+=("$1")
        isNonOptionArg=0
    elif [ "$1" == "--" ]; then
        isNonOptionArg=true
    elif [ "${1:0:1}" == "-" ]; then
        case $1 in
            -h | --help) PrintHelp; exit;;
            -e|--e) endpoint=$2;shift;;
            -l|--l|-list|--list) vmListFile=$2;shift;;
            -q|-quiet|--quiet) isQuiet=1;;
            -*) echo Error! Wrong argument: $1 >&2; exit;;
        esac
    else
        vmList+=("$1")
    fi
    shift
done

credfile=$(find /tmp/ -maxdepth 1 -name "x509up_*" )
if [ "$credfile" == "" ];then
    echo "credfile not found at /tmp" >&2
    exit 1
fi

if [ "$vmListFile" != ""  ]; then 
    if [ -s "$vmListFile" ]; then 
        while read line
        do
            vmList+=("$line")
        done < $vmListFile
    else
        echo listfile \'$vmListFile\' does not exist or empty. >&2
    fi
fi

numVM=${#vmList[@]}
if [ $numVM -eq 0  ]; then
    echo Input not set! Exit. >&2
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

for ((i=0;i<numVM;i++));do
    vm=${vmList[$i]}
    DeleteVM "$vm"
done

