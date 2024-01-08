#!/bin/bash

get_cpu_usage() {
server=$1
usage=$(ssh $server 'sar 1 3 | tail -1 | gawk "{print \$8}"')
result=$(echo "scale=2 ; 100 * $usage" | bc)
result_int=$(echo $result | cut -d'.' -f1)
echo $result_int
}

compute1=$(get_cpu_usage compute1)
compute2=$(get_cpu_usage compute2)

if [ $compute1 -ge $compute2 ]; then
echo "compute1"
else
echo "compute2"
fi