#!/bin/bash

# usage: . ./init.sh
# error to call it in this way: . init.sh

SCRIPT_PATH=`realpath ${BASH_SOURCE[0]}`
rundir=`dirname $SCRIPT_PATH`
vombin=$rundir/bin
for dir in "$vombin"; do
    if [ -d "$dir" ] ;then
        greptxt=`echo $PATH | grep "$dir"`
        if [ "$greptxt" == "" ]; then 
            PATH="${dir}:${PATH}"
        fi
    fi
done

# set valid life for the voms ticket 
# default to 1 month
validlife=24:00

export PATH
voms-proxy-init -valid $validlife -voms vo.nbis.se --rfc --dont_verify_ac
