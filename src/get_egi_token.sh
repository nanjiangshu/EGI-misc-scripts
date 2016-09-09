#!/bin/bash


curl  -k  --cert /tmp/x509up_u1000 -d '{"auth":{"voms": true, "tenantName": "EGI_bils"}}' -H "Content-type: application/json" https://cloud.recas.ba.infn.it:5000/v2.0/tokens 2>& 1 | tr '{' '\n' | grep 'id' | head -n 1 | grep 'id'

