LOGDIR="$HOME/process_monitor_logs"
THRESHOLD_CPU=30
THRESHOLD_MEM=20
WHITELIST=("sshd" "systemd" "bash" "python3" "nginx" "mysqld" "firefox")
mkdir -p "$LOGDIR"
TIMESTAMP="$(date '+%Y-%m-%d_%H%M%S')"
LOGFILE="$LOGDIR/monitor_$TIMESTAMP.log"

echo "=== Process Monitor run at $(date) ===" >> "$LOGFILE"

echo -e "\n-- Top CPU consumers --" >> "$LOGFILE"
ps aux --sort=-%cpu | head -n 15 >> "$LOGFILE"

echo -e "\n-- Top Memory consumers --" >> "$LOGFILE"
ps aux --sort=-%mem | head -n 15 >> "$LOGFILE"

echo -e "\n-- Processes exceeding CPU threshold ($THRESHOLD_CPU%) --" >> "$LOGFILE"
ps aux --no-heading | awk -v cpu="$THRESHOLD_CPU" '{
  user=$1; pid=$2; pcpu=$3; pmem=$4; cmd="";
  for(i=11;i<=NF;i++){cmd=cmd $i " "}
  if (pcpu+0 > cpu) printf("%s %s %s %s %s\n",user,pid,pcpu,pmem,cmd)
}' >> "$LOGFILE"
echo -e "\n-- Processes exceeding MEM threshold ($THRESHOLD_MEM%) --" >> "$LOGFILE"
ps aux --no-heading | awk -v mem="$THRESHOLD_MEM" '{
  user=$1; pid=$2; pcpu=$3; pmem=$4; cmd="";
  for(i=11;i<=NF;i++){cmd=cmd $i " "}
  if (pmem+0 > mem) printf("%s %s %s %s %s\n",user,pid,pcpu,pmem,cmd)
}' >> "$LOGFILE"
echo -e "\n-- Listening sockets (ss -tulnp) --" >> "$LOGFILE"
ss -tulnp >> "$LOGFILE" 2>/dev/null
echo -e "\n-- Unknown listening programs (not in whitelist) --" >> "$LOGFILE"
ss -tulnp 2>/dev/null | awk -F'"' '/users:\(/ {print $2}' | awk -F'[, ]' '{print $1}' | sort -u | while read prog; do
  if [ -z "$prog" ]; then continue; fi
  found=0
  for w in "${WHITELIST[@]}"; do
    if [[ "$prog" == "$w" ]]; then found=1; break; fi
  done
  if [ $found -eq 0 ]; then
    echo "UNKNOWN_LISTENER: $prog" >> "$LOGFILE"
  fi
done
echo -e "\n-- Summary: top CPU processes (name,count) --" >> "$LOGFILE"
ps aux --no-heading | awk '{print $11}' | sort | uniq -c | sort -nr | head -n 10 >> "$LOGFILE"

echo -e "\n-- Summary: top MEM processes (name,count) --" >> "$LOGFILE"
ps aux --no-heading | awk '{print $11}' | sort | uniq -c | sort -nr | head -n 10 >> "$LOGFILE"
echo -e "\n=== End of run ===" >> "$LOGFILE"
echo "Log saved to $LOGFILE"
