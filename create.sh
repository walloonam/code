#!/bin/bash
#가상머신 생성하는 shell

username=$(whoami)
nodes=$(compare_cpu)
echo "가상머신 생성하기"
echo -en "\t 가상머신 이름:"
read vname
vname=$(echo $vname | gawk '/^[a-z]{1}[a-z0-9]{4,9}$/{print $0}')
if [ -z $vname ]
then
        echo -en "\t\tWARNING : 잘못된 이름입니다.다시 시작합니다."
        read nnn
        continue
fi

check=true

while $check; do
echo "OS Menu:"
echo "1. CentOS 7"
echo "2. CentOS 8"

read -p "Choose an OS (1-2): " choice

case "$choice" in
        1)
                echo "You chose CentOS 7"
                # CentOS 7에 대한 동작 수행
                check=false
                vdisk="CentOS7.qcow2"
                ;;
        2)
                echo "You chose CentOS 8"
                vdisk="CentOS8.qcow2"
                check=false
                # CentOS 8에 대한 동작 수행
                ;;
        *)
                echo "Invalid choice. Please enter a number between 1 and 2."
                ;;
esac
done

check=true
while $check;
do
echo "flavor:"
echo "1. x.small(cpu=1, ram=1)"
echo "2. x.medium(cpu=2, ram=2)"
echo "3. x.large(cpu=4, ram=4)"

read -p "flavor선택(1-3): " choice

case "$choice" in
        1)
                echo "You chose x.small"
                vcpus=1
                vrams=1024
                check=false
                ;;
        2)
                echo "You chose x.medium"
                vcpus=2
                vrams=2048
                check=false
                ;;
        3)
                echo "You chose x.large"
                vcpus=4
                vrams=4096
                check=false
                ;;
        *)
                echo "Invalid choice. Please enter a number between 1 and 3."
                ;;
                esac

done
echo -en "\t가상머신 개수 : "
read vnum

echo $username
echo $vname
echo $vdisk
echo $vcpus
echo $vrams
echo $vnum
echo $nodes

echo "가상머신 설치를 시작합니다" ;
sleep 1

        ssh $nodes "ssh-keygen -q -N '' -f /shared/${vname}.pem ; cat /shared/${vname}.pem"
for (( i=1 ; i <= $vnum ; i++ ));
do
        vnames=${vname}-${i}
        ssh $nodes "make_vm $vnames $vcpus $vdisk $vrams $vname"

        sleep 3
# IP정보 확인되었다면
echo "[  ${i}번째 설치가 완료되었습니다 ]"
# 데이터베이스에 저장하기
mysql instance -u user2 -puser2 <<EOF
        INSERT INTO status VALUES ('$vnames','$vdisk' ,'','$username', '$nodes');
        INSERT INTO flavor VALUES ('$vnames','$vcpus', '$vrams');
EOF


if [ $? -eq 0 ]
then
echo "데이터베이스에 기록되었습니다"
else
echo "데이터베이스 기록 실패"


fi
while true; do
        result=$(mysql instance -u user2 -puser2  -se "SELECT vip FROM status WHERE name='$vnames';")
        if [ -n "$result" ]; then
              echo "$COLUMN_NAME 컬럼에 값이 들어왔습니다: $result"
               break
        else
            echo "아직 $COLUMN_NAME 컬럼에 값이 들어오지 않았습니다. 대>기 중..."
            sleep 10  # 1초 간격으로 확인 (원하는 시간으로 조절 가능)
       fi
done
done