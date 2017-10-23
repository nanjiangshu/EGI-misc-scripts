#!/bin/bash

# Filename:  create_VM_IT.sh
# Description: create  VM for the endpoint IT
# Author: Nanjiang Shu (nanjiang.shu@scilifelab.se)

progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""` 
usage="
Usage:  $progname -t TITLE -os OS_TPL -rs RESOURCE_TPL [-storage INT -st TITLE]
OPTIONS:
  -t                Title of the VM
  -os OS_TPL        OS template
                    supported tpl are ubuntu14, ubuntu14server, centos6, centos7
  -rs RESOURCE_TPL  Resource template
                    supported tpl are small, medium, large, mem.small, mem.medium, mem.large
  -script FILE      Init Script, (default: egibils.login)
  -storage INT      Add a block storage in GB
  -st      STR      Title for the storage, (default: njvol)
  -h, --help        Print this help message and exit

Created 2016-09-08, updated 2016-09-08, Nanjiang Shu

Examples
    $0 -t server1 -os ubuntu14 -rs large -storage 200 -st njvol2
"
PrintHelp(){ #{{{
    echo "$usage"
}
#}}}
IsProgExist(){ #{{{
    # usage: IsProgExist prog
    # prog can be both with or without absolute path
    type -P $1 &>/dev/null \
        || { echo The program \'$1\' is required but not installed. \
        Aborting $0 >&2; exit 1; }
    return 0
}
#}}}
IsPathExist(){ #{{{
# supply the effective path of the program 
    if ! test -d "$1"; then
        echo Directory \'$1\' does not exist. Aborting $0 >&2
        exit 1
    fi
}
#}}}
CreateVM(){ #{{{
    logfile=$logpath/${title}.createvm.log
    cat /dev/null > $logfile

    rtvalue_0=$(occi -e $endpoint --auth x509 --user-cred $credfile --voms -a create -r compute --mixin os_tpl#$os_tpl --mixin resource_tpl#$resource_tpl --attribute occi.core.title="$title" --context user_data="file://$PWD/$initscript")

    newid=
    if [[ "$rtvalue_0" =~ "$endpoint" ]];then
        echo "Successfully create a VM $rtvalue_0"
        newid=$(basename ${rtvalue_0})

        echo "ComputeNode: $rtvalue_0" >> $logfile
        # get the description of the newly created VM
        description=$(occi -e $endpoint --auth x509 --user-cred $credfile --voms -a describe --resource ${rtvalue_0})
        echo "$description" >> $logfile

        if [ "$storage" != "" ];then
            echo "Create a block storage of $storage GB and attach it to $rtvalue_0"
            rtvalue_2=$(occi -e  $endpoint --auth x509 --user-cred $credfile --voms -a create -r storage -t occi.storage.size="num($storage)",occi.core.title="$title_storage")
            if [[ "$rtvalue_2" =~ "$endpoint" ]];then
                echo "Successfully create a block volume $rtvalue_2"
                # link the block storage to the VM
                rtvalue_3=$(occi -e  $endpoint --auth x509 --user-cred $credfile --voms -a link -r $rtvalue_0 -j $rtvalue_2)
                if [[ "$rtvalue_3" =~ "$endpoint" ]];then
                    echo "Successfully linked $rtvalue_2 to $rtvalue_0"
                else
                    echo "Failed to link $rtvalue_2 to $rtvalue_0"
                fi
            else
                echo "Failed to create the block storage"
            fi
        fi
    else
        echo "Failed to create VM at $endpoint"
    fi

    echo "Detailed information of the VM output to $logfile"
} 
#}}}

if [ $# -lt 1 ]; then
    PrintHelp
    exit
fi

title=
endpoint=$ENDPOINT_IT
if [ "$ENDPOINT_IT" == "" ];then
    endpoint=http://cloud.recas.ba.infn.it:8787/occi
fi
storage=
initscript=egibils.login

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
            -t|--t) title=$2;shift;;
            -os|--os) os_tpl=$2;shift;;
            -rs|--rs) resource_tpl=$2;shift;;
            -storage|--storage) storage=$2;shift;;
            -st|--st) title_storage=$2;shift;;
            -script|--script) initscript=$2;shift;;
            -q|-quiet|--quiet) isQuiet=1;;
            -*) echo Error! Wrong argument: $1 >&2; exit;;
        esac
    else
        echo Error! Wrong argument: $1 >&2; exit
    fi
    shift
done

credfile=$(find /tmp/ -maxdepth 1 -name "x509up_*" )
if [ "$credfile" == "" ];then
    echo "credfile not found at /tmp" >&2
    exit 1
fi

rundir=`dirname $0`
basedir=$rundir/../
cd $basedir

logpath=$basedir/log/createvm/
if [ ! -d $logpath ];then
    mkdir -p $logpath
fi

if [ "$title" == "" ];then
    echo "title of the VM not set. exit"
    exit 1
fi

if [ "$os_tpl" == "" ];then
    echo "os_tpl not set. exit"
    exit 1
fi
if [ "$resource_tpl" == "" ];then
    echo "resource_tpl not set. exit"
    exit 1
fi

if [ "$storage" != "" ];then
    if [ "$title_storage" == "" ];then
        title_storage=njvol
    fi
fi

case $os_tpl in 
    ubuntu14)       os_tpl=303d8324-69a7-4372-be24-1d68703affd7;;
    ubuntu14server) os_tpl=0c1db362-f79e-469b-b9ba-db583c2b1230;;
    centos6)        os_tpl=25fad490-a822-402d-802d-f9b24f3f5acc;;
    centos7)        os_tpl=0de96743-4a12-4470-b8b2-6dc260977a40;;
    *) echo "unrecognized os_tpl=$os_tpl";exit 1;;
esac

case $resource_tpl in 
    small) resource_tpl=7;;
    medium)resource_tpl=8;;
    large) resource_tpl=9;;
    xlarge) resource_tpl=10;;
    xxlarge) resource_tpl=11;;
    4cpu-4GB-60dsk) resource_tpl=29;;
    4cpu-8GB-10dsk) resource_tpl=32;;
    16cpu-32GB-10dsk) resource_tpl=57;;
    *) echo "unrecognized resource_tpl=$resource_tpl";exit 1;;
esac


CreateVM
