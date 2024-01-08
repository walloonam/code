#!/bin/bash
#menu.sh

while [ 1 ]
do
        num=""
        clear
        echo -e "\t========================"
        echo -e "\t     가상머신 관리      "
        echo -e "\t========================"
        echo
        echo -e "\t 1) 가상머신 생성하기"
        echo -e "\t 2) 가상머신 확인하기"
        echo -e "\t 3) 가상머신 삭제하기"
        echo -e "\t 4) 마이그레이트 하기"
        echo
        echo -en "\t\t메뉴를 선택하세요 : "
        read num
        echo

        if [ $num -eq 1 ]
        then
                create
        elif [ $num -eq 2 ]
        then
                check
        elif [ $num -eq 3 ]
        then
                delete
        elif [ $num -eq 4 ]
        then
                migrate
        else
                echo "1~4중에 입력해주세요"

        fi
        echo -n "계속 진행하려면 아무키나 입력하세요"
        read nnn
done