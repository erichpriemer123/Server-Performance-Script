# Script will monitor system resources
# total cpu usage
# total memory usage
# total disk usage
# top 5 processes by cpu usage
# top 5 processes by mem usage 


#functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Get the load averages
# percentage of time processes spent running on cpu, spent in uninterupptable state, and waiting in run queue
# over 1,5,15 min periods.
# usage = n cores - perfect  utilization
# usage < n cores - under utilization
# usage > n cores - over utilization
cpu_load_avg_1min=$(uptime | awk -F'load average: ' '{print $2}' | cut -d ',' -f1 | tr -d ' ')
cpu_load_avg_5min=$(uptime | awk -F'load average: ' '{print $2}' | cut -d ',' -f2 | tr -d ' ')
cpu_load_avg_15min=$(uptime| awk -F'load average: ' '{print $2}' | cut -d ',' -f3 | tr -d ' ')

# Get the number of cpu cores 
cpu_core=$(nproc --all)

# Cpu Load Average percentage
# bc is used for calculations other than 
cpu_percentage_1min=$(echo "scale=2 ; $cpu_load_avg_1min / $cpu_core" | bc)
cpu_percentage_5min=$(echo "scale=2 ; $cpu_load_avg_5min / $cpu_core" | bc)
cpu_percentage_15min=$(echo "scale=2 ; $cpu_load_avg_15min / $cpu_core" | bc)
echo " "
echo "Cpu and system utilization =============="
echo "Load average 1 min: $cpu_percentage_1min"
echo "Load average 5 min: $cpu_percentage_5min"
echo "Load average 15 min: $cpu_percentage_15min"

# cpu utilization. top ran in batch mode 2 cycles 
cpu_utilization=$(top -b -n 2 | grep ^%Cpu | awk 'FNR == 2 {print}')
echo "Cpu Utilization: $cpu_utilization"

echo " "
echo "Memory =============="

# free memory
free_memory=$(free -m | awk 'FNR == 2 {print $4;}')
echo "Free memory (mibi): $free_memory"

# total memory 
total_memory=$(free -m | awk 'FNR == 2 {print $2;}')
echo "Total memory (mibi): $total_memory"

# used memory
used_memory=$(free -m | awk 'FNR == 2 {print $3;}')
echo "Used memory (mibi): $used_memory"

#free memory percentage
free_mem_percentage=$(echo "scale=2 ; $free_memory / $total_memory * 100" | bc)
echo "Percentage of Free Memory: $free_mem_percentage%"

echo " "
echo "Disk ================="

#total disk space
total_disk=$(df -h --total | awk 'FNR == 11 {print $2;}')
echo "Disk space: $total_disk"

#free disk space
free_disk=$(df -h --total | awk 'FNR == 11 {print $4;}')
echo "Free disk space: $free_disk"

#free disk percentage
free_disk_percentage=$(echo "scale=2 ; $free_disk / $total_disk * 100" | bc)
echo "Percentage of Free Disk: $free_disk_percentage%"

echo " "
#top 5 processes by cpu usage
top_5_cpu_usage=$(ps -eo pid,cmd,%cpu --sort -%cpu | head -n 6)
echo "Top 5 processes by cpu usage :"
echo "$top_5_cpu_usage"


#top 5 processes by memory usage
top_5_mem_usage=$(ps -eo pid,cmd,%mem --sort -%mem | head -n 6)
echo "Top 5 processes by memory usage :"
echo "$top_5_mem_usage"
