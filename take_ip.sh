#!/bin/bash
sleep 5

addr=""

while [ -z "$addr" ];
do
        addr=$(ip a | grep 211 | gawk '{print $2}' | gawk -F/ '{print $1}')
done


mysql instance -u user2 -puser2 -h 211.183.3.100<<EOF
        UPDATE status
        SET vip = '$addr'
        WHERE name = '$(hostname)'
EOF