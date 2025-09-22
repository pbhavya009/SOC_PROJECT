




LOG_FILE="$HOME/SOC_Project/suspicious_alerts.log"
CPU_THRESHOLD=70       # CPU usage % threshold
MEM_THRESHOLD=70       # Memory usage % threshold
KNOWN_PORTS=(22 80 443 3306)  # Common ports (adjust as needed)

echo "=== Monitoring Started at $(date) ===" >> $LOG_FILE


echo "Checking high CPU/Memory processes..." >> $LOG_FILE
ps aux --sort=-%cpu,-%mem | awk -v cpu=$CPU_THRESHOLD -v mem=$MEM_THRESHOLD 'NR>1 {if($3>cpu || $4>mem) print "Suspicious Process: "$0}' >> $LOG_FILE


echo "Checking for unknown services..." >> $LOG_FILE
ss -tulnp | awk -v known_ports="${KNOWN_PORTS[*]}" '
NR>1 {
    split(known_ports, ports_arr, " ");
    port=$5;
    sub(/.*:/,"",port);
    found=0;
    for(i in ports_arr){
        if(port==ports_arr[i]){
            found=1;
        }
    }
    if(found==0){
        print "Unknown Service Listening: "$0
    }
}' >> $LOG_FILE

echo "=== Monitoring Completed at $(date) ===" >> $LOG_FILE
echo "" >> $LOG_FILE

