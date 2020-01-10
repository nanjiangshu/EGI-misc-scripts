#!/bin/bash

rundir=`dirname $0`
rundir=`realpath  $rundir`
echo $rundir
data=(
'2019-01-01' '2019-01-31' 'January'
'2019-02-01' '2019-02-29' 'February'
'2019-03-01' '2019-03-31' 'March'
'2019-04-01' '2019-04-30' 'April'
'2019-05-01' '2019-05-31' 'May'
'2019-06-01' '2019-06-31' 'June'
'2019-07-01' '2019-07-31' 'July'
'2019-08-01' '2019-08-31' 'August'
'2019-09-01' '2019-09-30' 'September'
'2019-10-01' '2019-10-31' 'October'
'2019-11-01' '2019-11-30' 'November'
'2019-12-01' '2019-12-31' 'December'
)

for ((i=0; i< 12; i++)); do
    ((idx1=i*3))
    ((idx2=i*3+1))
    ((idx3=i*3+2))
    startdate=${data[$idx1]}
    enddate=${data[$idx2]}
    month=${data[$idx3]}
#     echo $startdate
#     echo $enddate 
#     echo $month
    $rundir/stat_usage_web_server.sh -start-date $startdate -end-date $enddate scampi2 proq3 pconsc3 topcons2 boctopus2 subcons prodres -onlydata > $month.txt
    echo "$month.txt output"
done
