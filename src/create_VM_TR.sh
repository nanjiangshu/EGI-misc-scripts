#!/bin/bash

# Filename: create_VM_TR.sh
# Description: create  VM for the endpoint TR
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
        # create public ip
        rtvalue_1=$(occi -e  $endpoint --auth x509 --user-cred $credfile --voms -a link -r $rtvalue_0 --link $floating_url --mixin "$floating_pool")
        if [[ "$rtvalue_1" =~ "$endpoint" ]]; then
            echo "Successfully assigned a public IP $rtvalue_1"
        fi

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
endpoint=$ENDPOINT_TR
if [ "$ENDPOINT_TR" == "" ];then
    endpoint=http://fcctrl.ulakbim.gov.tr:8787/occi1.1
fi
storage=
initscript=egibils.login
floating_url=http://fcctrl.ulakbim.gov.tr:8787/occi1.1/network/floating
floating_pool=http://schemas.openstack.org/network/floatingippool#public

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
    ubuntu14)       os_tpl=396f3b94-e1b0-4e78-a10b-de4e8326043c;;
    ubuntu14server) os_tpl=661a2b1e-8a10-4ed2-ae6b-5a56c50e62bc;;
    centos6)        os_tpl=6a06cf46-5b74-4be7-a39e-5c88b9da1720;;
    centos7)        os_tpl=0b195569-4f96-434f-a41c-60e982dfdb61;;
    *) echo "unrecognized os_tpl=$os_tpl";exit 1;;
esac

case $resource_tpl in 
    small) resource_tpl=bc5ed503-c066-4d00-b99e-6bef76bcb732;;
    medium)resource_tpl=21e13d6a-86ad-4d15-8762-cc79a04a2f84;;
    large) resource_tpl=a2497383-0bde-4a51-89f0-dc424e74070a;;
    mem.small) resource_tpl=a4e440c0-0e3f-4e2d-9eb2-0188cc55854e;;
    mem.medium) resource_tpl=5f24eb01-8028-42f5-a90f-4adadc617896;;
    mem.large)  resource_tpl=11bfe5ae-9cd0-4d34-af39-7a480ca61254;;
    *) echo "unrecognized resource_tpl=$resource_tpl";exit 1;;
esac


CreateVM
