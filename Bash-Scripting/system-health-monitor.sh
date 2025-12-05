#!/bin/bash

read load1 load5 load15 <<< "$(awk '{print $1, $2, $3}' /proc/loadavg)"

cpu_cores=$(nproc)

avg_per_one_min="$(echo "scale=2; ($load1 / $cpu_cores) * 100" | bc)"
avg_per_five_min="$(echo "scale=2; ($load5 / $cpu_cores) * 100" | bc)"
avg_per_fifteen_min="$(echo "scale=2; ($load15 / $cpu_cores) * 100" | bc)"

echo ""
echo "====Monitor CPU usage===="
echo "Average load per minute: $avg_per_one_min %"
echo "Average load per 5 minutes: $avg_per_five_min %"
echo "Average load per 15 minutes: $avg_per_fifteen_min %"
echo ""

for avg in avg_per_one_min avg_per_five_min avg_per_fifteen_min; do
    value=${!avg}
    if (( $(echo "$value < 30" | bc -l) )); then
        echo -e "\e[42mAverage load per minute: $value% | LOW load\e[0m \n"
    elif (( $(echo "$value >= 30" | bc -l) && $(echo "$value <= 70" | bc -l) )); then
        echo -e "\e[43mAverage load per minute: $value% | MEDIUM load\e[0m \n"
    else
        echo -e "\e[41mAverage load per minute: $value% | HIGH load!\e[0m \n"
    fi
done


mem_info=$(cat /proc/meminfo | head -5 | awk '{ \
  gb = $2 / (1024 * 1024)
  printf "%-20s %.2f GB\n", $1, gb
}')

echo "====Memory use===="
echo "$mem_info"
echo ""

disk_space="$(df -h | awk '$6=="/" {print $1, $2, $3, $4, $5, $6 }')"

read disk_partition disk_size used_size free_size percentage_uses_size mount <<< "$disk_space"

echo "====Disk space===="
echo "Disk partition: $disk_partition
Disk size: $disk_size
Used size: $used_size
Free size: $free_size
Used size in percentage: $percentage_uses_size
Mount: $mount
"

echo ""

running_processes=$(ps -e -o pid,comm,state | awk ' $3=="R" {print $0}')

echo "====Running processes===="
echo "$running_processes"
echo ""

