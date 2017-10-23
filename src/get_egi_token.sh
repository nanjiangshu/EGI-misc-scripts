#!/bin/bash

credfile=$(find /tmp/ -maxdepth 1 -name "x509up_*" )
if [ "$credfile" == "" ];then
    echo "credfile not found at /tmp" >&2
    exit 1
fi

curl  -k  --cert $credfile  -d '{"auth":{"voms": true, "tenantName": "EGI_bils"}}' -H "Content-type: application/json" https://cloud.recas.ba.infn.it:5000/v2.0/tokens 2>& 1 | tr '{' '\n' | grep 'id' | head -n 1 | grep 'id'

