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

echo "compute1 CPU usage: $compute1%"
echo "compute2 CPU usage: $compute2%"

# Check if the absolute difference in CPU usage is greater than or equal to 1000
cpu_diff=$((compute1 - compute2))
abs_cpu_diff=${cpu_diff#-}  # Get absolute value of cpu_diff

if [ $abs_cpu_diff -ge 1000 ]; then
   if [ $compute1 -ge $compute2 ]; then
        echo "Live migrating from compute1 to compute2..."
        change=$(ssh compute1 "virt-top --stream -b -n 2 | gawk '$7 > 0 && /R/ {print $8, $10}' | sort -k2n | head -n 1 | gawk '{print $2}'")
        ssh compute1 "virsh migrate --live --persistent --undefinesource $change qemu+ssh://compute2/system"
  mysql -u user2 -puser2 instance -se "UPDATE status SET node = 'compute2' WHERE name ='$change';"      
	else
         echo "Live migrating from compute2 to compute1..."
        change=$(ssh compute2 "virt-top --stream -b -n 2 | gawk '$7 > 0 && /R/ {print $8, $10}' | sort -k2n | head -n 1 | gawk '{print $2}'")
        ssh compute2 "virsh migrate --live --persistent --undefinesource $change qemu+ssh://compute1/system"
					mysql -u user2 -puser2 instance -se "UPDATE status SET node = 'compute1' WHERE name ='$change';"         
# Add live migration command from compute2 to compute1 here
    fi
else
          echo "No live migration needed."
 fi