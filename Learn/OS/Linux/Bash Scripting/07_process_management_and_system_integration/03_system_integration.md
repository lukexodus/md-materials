## System Integration


### Cron Job Scripting

Cron jobs are the backbone of automated system administration, allowing scripts to run at predetermined intervals without manual intervention. Effective cron job scripting requires understanding both the cron syntax and robust script design principles.

The cron daemon reads crontab files that define when and how often scripts should execute. Each cron entry follows the format: `minute hour day-of-month month day-of-week command`. Understanding this timing mechanism is crucial for system integration tasks like log rotation, backup operations, and system maintenance.

When writing scripts for cron execution, several considerations become critical. Scripts must handle the limited environment that cron provides, including minimal PATH variables and absence of interactive shell features. Absolute paths should be used for all executables and files, and environment variables should be explicitly set within the script.

**Key points** for cron job scripting include proper error handling, logging mechanisms, and lock file implementation to prevent concurrent executions. Scripts should redirect output appropriately since cron jobs run without a terminal, and any output not redirected will be emailed to the system administrator.

**Example** of a robust cron job script:

```bash
#!/bin/bash
# Backup script with proper error handling and logging

LOGFILE="/var/log/backup.log"
LOCKFILE="/var/run/backup.lock"
BACKUP_DIR="/backup"
SOURCE_DIR="/home"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Check if script is already running
if [ -f "$LOCKFILE" ]; then
    log_message "ERROR: Backup already running (lock file exists)"
    exit 1
fi

# Create lock file
echo $$ > "$LOCKFILE"

# Cleanup function
cleanup() {
    rm -f "$LOCKFILE"
}

# Set trap for cleanup
trap cleanup EXIT

# Perform backup
log_message "Starting backup process"
if tar -czf "$BACKUP_DIR/backup_$(date +%Y%m%d).tar.gz" "$SOURCE_DIR" 2>> "$LOGFILE"; then
    log_message "Backup completed successfully"
else
    log_message "ERROR: Backup failed"
    exit 1
fi
```

### Service Management Scripts

Service management scripts provide standardized control over system services, following established conventions for starting, stopping, restarting, and checking service status. These scripts typically reside in `/etc/init.d/` or work with systemd unit files for modern Linux distributions.

Traditional System V init scripts follow a specific structure with functions for each service operation. The script must handle process identification, graceful shutdown procedures, and status reporting. Modern systemd services use unit files with declarative configuration, but custom scripts may still be necessary for complex service management scenarios.

Process management within service scripts requires careful handling of PID files, signal management, and dependency resolution. Scripts must account for service dependencies, resource requirements, and proper cleanup procedures when services terminate unexpectedly.

**Key points** for service management include implementing proper signal handling for graceful shutdowns, maintaining accurate PID tracking, and providing meaningful status information. Scripts should handle edge cases like orphaned processes, corrupted PID files, and resource conflicts.

**Example** of a service management script:

```bash
#!/bin/bash
# Service management script for custom application

SERVICE_NAME="myapp"
SERVICE_USER="appuser"
SERVICE_HOME="/opt/myapp"
SERVICE_EXEC="$SERVICE_HOME/bin/myapp"
PID_FILE="/var/run/$SERVICE_NAME.pid"
LOCK_FILE="/var/lock/$SERVICE_NAME"

start() {
    echo -n "Starting $SERVICE_NAME: "
    
    # Check if service is already running
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "already running (PID: $PID)"
            return 1
        else
            rm -f "$PID_FILE"
        fi
    fi
    
    # Start the service
    sudo -u "$SERVICE_USER" "$SERVICE_EXEC" --daemon --pidfile="$PID_FILE"
    
    if [ $? -eq 0 ]; then
        touch "$LOCK_FILE"
        echo "started"
        return 0
    else
        echo "failed"
        return 1
    fi
}

stop() {
    echo -n "Stopping $SERVICE_NAME: "
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill -TERM "$PID" 2>/dev/null
        
        # Wait for graceful shutdown
        for i in {1..30}; do
            if ! ps -p "$PID" > /dev/null 2>&1; then
                break
            fi
            sleep 1
        done
        
        # Force kill if still running
        if ps -p "$PID" > /dev/null 2>&1; then
            kill -KILL "$PID" 2>/dev/null
        fi
        
        rm -f "$PID_FILE" "$LOCK_FILE"
        echo "stopped"
        return 0
    else
        echo "not running"
        return 1
    fi
}

status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "$SERVICE_NAME is running (PID: $PID)"
            return 0
        else
            echo "$SERVICE_NAME is dead but PID file exists"
            return 1
        fi
    else
        echo "$SERVICE_NAME is not running"
        return 3
    fi
}

case "$1" in
    start) start ;;
    stop) stop ;;
    restart) stop && start ;;
    status) status ;;
    *) echo "Usage: $0 {start|stop|restart|status}" ;;
esac
```

### System Startup Scripts

System startup scripts execute during the boot process to initialize services, configure system parameters, and prepare the environment for normal operation. These scripts must be designed to handle the unique constraints of the boot environment, including limited filesystem availability and specific execution order requirements.

Boot scripts typically fall into several categories: early boot scripts that run before most filesystems are mounted, system initialization scripts that configure basic system parameters, and service startup scripts that launch user-space applications. Each category has specific requirements and limitations that must be considered during script development.

The boot environment presents unique challenges including limited PATH variables, potential filesystem unavailability, and strict timing requirements. Scripts must be robust enough to handle partial system states and should include appropriate error handling to prevent boot failures.

**Key points** for startup scripts include minimizing external dependencies, implementing proper error recovery, and ensuring scripts can handle interrupted executions. Scripts should be idempotent, meaning they can be run multiple times without adverse effects.

**Example** of a system startup script:

```bash
#!/bin/bash
# System startup script for custom network configuration

# chkconfig: 35 99 99
# description: Custom network configuration script

. /etc/rc.d/init.d/functions

USER="root"
DAEMON="network-config"
ROOT_DIR="/usr/local/network-config"

SERVER="$ROOT_DIR/network-config.sh"
LOCK_FILE="/var/lock/subsys/network-config"

do_start() {
    if [ ! -f "$LOCK_FILE" ] ; then
        echo -n "Starting $DAEMON: "
        runuser -l "$USER" -c "$SERVER" && echo_success || echo_failure
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch $LOCK_FILE
    else
        echo "$DAEMON is locked."
        RETVAL=1
    fi
}
do_stop() {
    echo -n $"Shutting down $DAEMON: "
    pid=$(ps -aefw | grep "$DAEMON" | grep -v " grep " | awk '{print $2}')
    kill -9 $pid > /dev/null 2>&1
    [ $? -eq 0 ] && echo_success || echo_failure
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && rm -f $LOCK_FILE
}

case "$1" in
    start)
        do_start
        ;;
    stop)
        do_stop
        ;;
    restart)
        do_stop
        do_start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        RETVAL=1
esac

exit $RETVAL
```

### Resource Monitoring and Alerts

Resource monitoring scripts continuously track system metrics like CPU usage, memory consumption, disk space, and network activity to ensure system health and performance. These scripts must balance monitoring frequency with system overhead while providing timely alerts for critical conditions.

Effective monitoring requires establishing baseline metrics, setting appropriate thresholds, and implementing escalation procedures. Scripts should collect data efficiently, store historical information for trend analysis, and provide actionable alerts that help administrators respond to issues before they become critical.

Alert mechanisms can include email notifications, log entries, SNMP traps, or integration with monitoring systems. Scripts should implement rate limiting to prevent alert flooding and should provide clear, actionable information in alert messages.

**Key points** for monitoring scripts include efficient data collection methods, appropriate threshold setting, and reliable alert delivery mechanisms. Scripts should handle transient conditions gracefully and provide historical context for performance trends.

**Example** of a comprehensive monitoring script:

```bash
#!/bin/bash
# System resource monitoring script with alerts

CONFIG_FILE="/etc/monitoring/config.conf"
LOG_FILE="/var/log/system_monitor.log"
ALERT_LOG="/var/log/alerts.log"
TEMP_DIR="/tmp/monitoring"

# Default thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
LOAD_THRESHOLD=5.0

# Load configuration if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Create temp directory
mkdir -p "$TEMP_DIR"

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Alert function
send_alert() {
    local severity=$1
    local message=$2
    local alert_msg="[$severity] $(date '+%Y-%m-%d %H:%M:%S') - $message"
    
    echo "$alert_msg" >> "$ALERT_LOG"
    
    # Send email alert if configured
    if [ -n "$ALERT_EMAIL" ]; then
        echo "$alert_msg" | mail -s "System Alert: $severity" "$ALERT_EMAIL"
    fi
    
    # Send to syslog
    logger -p user.warn "$alert_msg"
}

# CPU monitoring
check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    cpu_usage=${cpu_usage%.*}  # Remove decimal part
    
    echo "CPU_USAGE:$cpu_usage" > "$TEMP_DIR/cpu"
    
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        send_alert "WARNING" "High CPU usage: ${cpu_usage}%"
    fi
    
    log_message "CPU Usage: ${cpu_usage}%"
}

# Memory monitoring
check_memory() {
    local memory_info=$(free | grep Mem)
    local total_mem=$(echo $memory_info | awk '{print $2}')
    local used_mem=$(echo $memory_info | awk '{print $3}')
    local memory_percent=$((used_mem * 100 / total_mem))
    
    echo "MEMORY_USAGE:$memory_percent" > "$TEMP_DIR/memory"
    
    if [ "$memory_percent" -gt "$MEMORY_THRESHOLD" ]; then
        send_alert "WARNING" "High memory usage: ${memory_percent}%"
    fi
    
    log_message "Memory Usage: ${memory_percent}%"
}

# Disk monitoring
check_disk() {
    df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5 " " $1}' | while read line; do
        usage=$(echo $line | awk '{print $1}' | sed 's/%//g')
        partition=$(echo $line | awk '{print $2}')
        
        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
            send_alert "CRITICAL" "High disk usage on $partition: ${usage}%"
        fi
        
        log_message "Disk Usage $partition: ${usage}%"
    done
}

# Load average monitoring
check_load() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | sed 's/^[ \t]*//')
    
    echo "LOAD_AVERAGE:$load_avg" > "$TEMP_DIR/load"
    
    if (( $(echo "$load_avg > $LOAD_THRESHOLD" | bc -l) )); then
        send_alert "WARNING" "High load average: $load_avg"
    fi
    
    log_message "Load Average: $load_avg"
}

# Network monitoring
check_network() {
    local network_errors=$(netstat -i | awk 'NR>2 {errors+=$4} END {print errors+0}')
    
    echo "NETWORK_ERRORS:$network_errors" > "$TEMP_DIR/network"
    
    if [ "$network_errors" -gt 100 ]; then
        send_alert "WARNING" "High network errors: $network_errors"
    fi
    
    log_message "Network Errors: $network_errors"
}

# Process monitoring
check_processes() {
    local zombie_count=$(ps aux | awk '{print $8}' | grep -c Z)
    
    if [ "$zombie_count" -gt 5 ]; then
        send_alert "WARNING" "High zombie process count: $zombie_count"
    fi
    
    log_message "Zombie Processes: $zombie_count"
}

# Main monitoring function
run_monitoring() {
    log_message "Starting system monitoring cycle"
    
    check_cpu
    check_memory
    check_disk
    check_load
    check_network
    check_processes
    
    log_message "Monitoring cycle completed"
}

# Generate summary report
generate_report() {
    local report_file="/tmp/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "System Monitoring Report - $(date)"
        echo "========================================"
        echo
        
        if [ -f "$TEMP_DIR/cpu" ]; then
            echo "CPU Usage: $(cat $TEMP_DIR/cpu | cut -d: -f2)%"
        fi
        
        if [ -f "$TEMP_DIR/memory" ]; then
            echo "Memory Usage: $(cat $TEMP_DIR/memory | cut -d: -f2)%"
        fi
        
        if [ -f "$TEMP_DIR/load" ]; then
            echo "Load Average: $(cat $TEMP_DIR/load | cut -d: -f2)"
        fi
        
        echo
        echo "Recent Alerts:"
        echo "=============="
        tail -10 "$ALERT_LOG" 2>/dev/null || echo "No recent alerts"
        
    } > "$report_file"
    
    echo "Report generated: $report_file"
}

# Command line interface
case "$1" in
    start|monitor)
        run_monitoring
        ;;
    report)
        generate_report
        ;;
    *)
        echo "Usage: $0 {start|monitor|report}"
        echo "  start/monitor - Run monitoring cycle"
        echo "  report       - Generate system report"
        exit 1
        ;;
esac
```

**Conclusion**

System integration through bash scripting requires understanding the specific requirements and constraints of each integration point. Cron job scripts must handle limited environments and provide robust error handling. Service management scripts need proper process control and status reporting. Startup scripts must work within boot environment limitations. Resource monitoring scripts require efficient data collection and reliable alerting mechanisms.

**Next steps** for mastering system integration scripting include implementing centralized logging systems, developing standardized error handling libraries, creating configuration management frameworks, and integrating with enterprise monitoring solutions.

---

