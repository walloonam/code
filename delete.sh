#!/bin/bash

echo "가상머신 삭제하기"
current_user=$(whoami)
echo "현재 사용자는 $current_user 입니다."

query1="SELECT name FROM status WHERE username = '$current_user';"
result=$(mysql instance -u user2 -puser2 -se "$query1" )

echo "사용자 $current_user 가 생성한 인스턴스는 다음과 같습니다."
echo "$result"

echo -en "\t가상머신 이름을 선택하십시오. "
read vm_name

query2="SELECT node FROM status WHERE name = '$vm_name';"
node=$(mysql instance -u user2 -puser2 -e "$query2" --skip-column-names)

result=$(mysql instance -u user2 -puser2 -se "SELECT name FROM status WHERE name = '$vm_name';")

echo $node
echo $result

if [ "$result" = "$vm_name" ]; then
echo "$vm_name 를 삭제합니다."
        sudo ssh $node "virsh destroy $vm_name"
sleep 5
sudo ssh $node "virsh undefine $vm_name --remove-all-storage"
sleep 5
sleep 10
query3="DELETE FROM status WHERE name = '$vm_name';"
query4="DELETE FROM flavor WHERE name = '$vm_name';"
mysql instance -u user2 -puser2  -se "$query3"
mysql instance -u user2 -puser2  -se "$query4"

echo " $vm_name 가 삭제되었습니다."
   else
echo " '$vm_name'이(가) 존재하지 않습니다. 다시 입력해주세요."
  fi