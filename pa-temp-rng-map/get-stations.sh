#!/bin/bash
END_DATE=99991231

cat $1 | tr -d \" | awk -F, '{print $1}' | \
    tail -n +2 | sort | uniq | \
while read station
do
    grep $station $2 | grep $END_DATE | awk \
        '{  st=substr($0,75,11);
            lat=substr($0,273,8);
            lng=substr($0,283,8);
            print st "," lat "," lng
        }'
done
