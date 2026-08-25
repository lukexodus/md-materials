## System Administration Scripts


### User Management Automation

User management automation reduces manual effort and ensures consistent user provisioning, modification, and removal across systems while maintaining security standards.

Create comprehensive user provisioning scripts that handle account creation, group assignment, and initial configuration:

```bash
#!/bin/bash
# User provisioning script

create_user() {
    local username="$1"
    local full_name="$2"
    local department="$3"
    local role="$4"
    
    # Validate input
    if [[ ! "$username" =~ ^[a-z][a-z0-9_-]{2,31}$ ]]; then
        echo "Invalid username format" >&2
        return 1
    fi
    
    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists" >&2
        return 1
    fi
    
    # Create user with home directory
    useradd -m -c "$full_name" -s /bin/bash "$username"
    
    # Set initial password (force change on first login)
    initial_password=$(openssl rand -base64 12)
    echo "$username:$initial_password" | chpasswd
    chage -d 0 "$username"
    
    # Add to appropriate groups based on role
    case "$role" in
        "developer")
            usermod -a -G developers,docker "$username"
            ;;
        "admin")
            usermod -a -G administrators,sudo "$username"
            ;;
        "analyst")
            usermod -a -G analysts,reports "$username"
            ;;
    esac
    
    # Create user directory structure
    setup_user_directories "$username" "$department"
    
    # Log user creation
    logger "User $username created for $department department"
    
    echo "User $username created successfully"
    echo "Initial password: $initial_password"
    echo "Password must be changed on first login"
}

setup_user_directories() {
    local username="$1"
    local department="$2"
    local home_dir="/home/$username"
    
    # Create standard directories
    mkdir -p "$home_dir"/{bin,tmp,projects,documents}
    
    # Set up SSH directory
    mkdir -p "$home_dir/.ssh"
    chmod 700 "$home_dir/.ssh"
    
    # Create department-specific directories
    case "$department" in
        "IT")
            mkdir -p "$home_dir"/{scripts,configs,monitoring}
            ;;
        "Development")
            mkdir -p "$home_dir"/{code,repos,deployments}
            ;;
        "Data")
            mkdir -p "$home_dir"/{datasets,analysis,reports}
            ;;
    esac
    
    # Set proper ownership
    chown -R "$username:$username" "$home_dir"
    chmod 750 "$home_dir"
}
```

Implement bulk user management operations:

```bash
# Bulk user operations
bulk_user_operations() {
    local csv_file="$1"
    local operation="$2"
    
    # Validate CSV file
    if [[ ! -f "$csv_file" ]]; then
        echo "CSV file not found: $csv_file" >&2
        return 1
    fi
    
    # Process CSV file
    while IFS=',' read -r username full_name department role email; do
        # Skip header line
        [[ "$username" == "username" ]] && continue
        
        case "$operation" in
            "create")
                create_user "$username" "$full_name" "$department" "$role"
                ;;
            "disable")
                disable_user "$username"
                ;;
            "remove")
                remove_user "$username"
                ;;
        esac
    done < "$csv_file"
}

disable_user() {
    local username="$1"
    
    # Lock account
    usermod -L "$username"
    
    # Expire account
    chage -E 0 "$username"
    
    # Move home directory
    if [[ -d "/home/$username" ]]; then
        mv "/home/$username" "/home/disabled_$username"
    fi
    
    # Log action
    logger "User $username disabled"
}

audit_user_accounts() {
    local output_file="/tmp/user_audit_$(date +%Y%m%d).csv"
    
    echo "Username,UID,GID,Home,Shell,Last_Login,Password_Age,Groups" > "$output_file"
    
    while IFS=: read -r username password uid gid gecos home shell; do
        # Skip system accounts
        [[ "$uid" -lt 1000 ]] && continue
        
        # Get last login
        last_login=$(lastlog -u "$username" 2>/dev/null | tail -1 | awk '{print $4" "$5" "$6}')
        
        # Get password age
        password_age=$(chage -l "$username" | grep "Last password change" | cut -d: -f2)
        
        # Get groups
        groups=$(groups "$username" | cut -d: -f2)
        
        echo "$username,$uid,$gid,$home,$shell,$last_login,$password_age,$groups" >> "$output_file"
    done < /etc/passwd
    
    echo "User audit saved to $output_file"
}
```

### System Maintenance and Cleanup

System maintenance scripts automate routine tasks to keep systems running efficiently and prevent issues from accumulating over time.

Create comprehensive system cleanup routines:

```bash
#!/bin/bash
# System cleanup and maintenance script

system_cleanup() {
    local log_file="/var/log/system_cleanup.log"
    
    {
        echo "=== System Cleanup Started: $(date) ==="
        
        # Clean package cache
        cleanup_packages
        
        # Clean log files
        cleanup_logs
        
        # Clean temporary files
        cleanup_temp_files
        
        # Clean user cache
        cleanup_user_caches
        
        # Update locate database
        updatedb
        
        # Generate summary report
        generate_cleanup_report
        
        echo "=== System Cleanup Completed: $(date) ==="
    } | tee -a "$log_file"
}

cleanup_packages() {
    echo "Cleaning package cache..."
    
    # Clean package manager cache
    if command -v apt-get >/dev/null 2>&1; then
        apt-get clean
        apt-get autoclean
        apt-get autoremove -y
    elif command -v yum >/dev/null 2>&1; then
        yum clean all
        package-cleanup --leaves
    fi
    
    # Clean snap packages
    if command -v snap >/dev/null 2>&1; then
        snap list --all | awk '/disabled/{print $1, $3}' | \
        while read snapname revision; do
            snap remove "$snapname" --revision="$revision"
        done
    fi
}

cleanup_logs() {
    echo "Cleaning log files..."
    
    # Archive old logs
    find /var/log -name "*.log" -type f -mtime +30 -exec gzip {} \;
    
    # Remove very old archived logs
    find /var/log -name "*.gz" -type f -mtime +90 -delete
    
    # Clean journal logs
    if command -v journalctl >/dev/null 2>&1; then
        journalctl --vacuum-time=30d
        journalctl --vacuum-size=500M
    fi
    
    # Clean syslog
    if [[ -f /var/log/syslog ]]; then
        tail -10000 /var/log/syslog > /tmp/syslog.tmp
        mv /tmp/syslog.tmp /var/log/syslog
    fi
}

cleanup_temp_files() {
    echo "Cleaning temporary files..."
    
    # Clean /tmp (files older than 7 days)
    find /tmp -type f -mtime +7 -delete 2>/dev/null
    find /tmp -type d -empty -delete 2>/dev/null
    
    # Clean /var/tmp
    find /var/tmp -type f -mtime +30 -delete 2>/dev/null
    
    # Clean browser caches
    find /home/*/.*cache* -type f -mtime +30 -delete 2>/dev/null
    
    # Clean thumbnail caches
    find /home/*/.thumbnails -type f -mtime +30 -delete 2>/dev/null
}

disk_usage_monitoring() {
    local threshold=80
    local alert_file="/tmp/disk_alerts.txt"
    
    echo "Disk Usage Report - $(date)" > "$alert_file"
    echo "=================================" >> "$alert_file"
    
    df -h | while read filesystem size used avail percent mountpoint; do
        # Skip header and non-disk filesystems
        [[ "$filesystem" == "Filesystem" ]] && continue
        [[ "$filesystem" =~ ^(tmpfs|udev|devpts) ]] && continue
        
        # Extract percentage number
        usage_percent="${percent%?}"
        
        if [[ "$usage_percent" -gt "$threshold" ]]; then
            echo "WARNING: $mountpoint is ${percent} full" >> "$alert_file"
            echo "  Filesystem: $filesystem" >> "$alert_file"
            echo "  Size: $size, Used: $used, Available: $avail" >> "$alert_file"
            echo "" >> "$alert_file"
            
            # Find largest directories
            echo "Largest directories in $mountpoint:" >> "$alert_file"
            du -h "$mountpoint" 2>/dev/null | sort -hr | head -10 >> "$alert_file"
            echo "" >> "$alert_file"
        fi
    done
    
    # Send alert if any disks are over threshold
    if [[ -s "$alert_file" ]]; then
        mail -s "Disk Usage Alert - $(hostname)" admin@company.com < "$alert_file"
    fi
}
```

Implement service health monitoring and maintenance:

```bash
# Service monitoring and maintenance
service_health_check() {
    local services=("apache2" "mysql" "postgresql" "nginx" "ssh")
    local failed_services=()
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            failed_services+=("$service")
            
            # Attempt to restart service
            echo "Attempting to restart $service..."
            if systemctl restart "$service"; then
                echo "$service restarted successfully"
                logger "Service $service was restarted by maintenance script"
            else
                echo "Failed to restart $service"
                logger "CRITICAL: Service $service failed to restart"
            fi
        fi
    done
    
    # Generate service status report
    generate_service_report
}

generate_service_report() {
    local report_file="/var/log/service_status_$(date +%Y%m%d).txt"
    
    {
        echo "Service Status Report - $(date)"
        echo "==============================="
        echo
        
        systemctl list-units --type=service --state=running | head -20
        echo
        
        echo "Failed Services:"
        systemctl list-units --type=service --state=failed
        echo
        
        echo "System Load:"
        uptime
        echo
        
        echo "Memory Usage:"
        free -h
        echo
        
        echo "Disk Usage:"
        df -h
        
    } > "$report_file"
    
    echo "Service report saved to $report_file"
}
```

### Backup and Recovery Systems

Comprehensive backup and recovery systems ensure data protection and business continuity through automated, tested, and reliable backup processes.

Create flexible backup scripts supporting multiple strategies:

```bash
#!/bin/bash
# Comprehensive backup system

# Configuration
BACKUP_CONFIG="/etc/backup/backup.conf"
BACKUP_BASE_DIR="/backup"
LOG_FILE="/var/log/backup.log"
RETENTION_DAYS=30
ENCRYPTION_KEY="/etc/backup/backup.key"

# Load configuration
source "$BACKUP_CONFIG" 2>/dev/null || {
    echo "Backup configuration not found" >&2
    exit 1
}

perform_backup() {
    local backup_type="$1"
    local backup_name="$2"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$BACKUP_BASE_DIR/$backup_name/$timestamp"
    
    log_message "Starting $backup_type backup: $backup_name"
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    case "$backup_type" in
        "files")
            backup_files "$backup_name" "$backup_dir"
            ;;
        "database")
            backup_database "$backup_name" "$backup_dir"
            ;;
        "system")
            backup_system "$backup_name" "$backup_dir"
            ;;
        "incremental")
            backup_incremental "$backup_name" "$backup_dir"
            ;;
    esac
    
    # Compress and encrypt backup
    if [[ -d "$backup_dir" ]]; then
        compress_and_encrypt "$backup_dir"
        cleanup_old_backups "$backup_name"
    fi
    
    log_message "Completed $backup_type backup: $backup_name"
}

backup_files() {
    local backup_name="$1"
    local backup_dir="$2"
    local source_dirs="${FILE_BACKUP_DIRS[$backup_name]}"
    local exclude_file="/etc/backup/exclude_${backup_name}.txt"
    
    # Create exclude file if it doesn't exist
    [[ ! -f "$exclude_file" ]] && touch "$exclude_file"
    
    # Perform backup using rsync
    rsync -av \
        --exclude-from="$exclude_file" \
        --link-dest="$BACKUP_BASE_DIR/$backup_name/latest" \
        $source_dirs \
        "$backup_dir/"
    
    # Update latest symlink
    ln -sfn "$backup_dir" "$BACKUP_BASE_DIR/$backup_name/latest"
}

backup_database() {
    local backup_name="$1"
    local backup_dir="$2"
    local db_type="${DB_BACKUP_TYPE[$backup_name]}"
    local db_name="${DB_BACKUP_NAME[$backup_name]}"
    
    case "$db_type" in
        "mysql")
            mysqldump --single-transaction --routines --triggers \
                --user="$DB_USER" --password="$DB_PASSWORD" \
                "$db_name" > "$backup_dir/${db_name}.sql"
            ;;
        "postgresql")
            pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$db_name" \
                > "$backup_dir/${db_name}.sql"
            ;;
        "mongodb")
            mongodump --host "$DB_HOST" --db "$db_name" \
                --out "$backup_dir"
            ;;
    esac
    
    # Verify backup integrity
    if [[ -f "$backup_dir/${db_name}.sql" ]]; then
        if [[ $(wc -l < "$backup_dir/${db_name}.sql") -gt 10 ]]; then
            log_message "Database backup verified: $db_name"
        else
            log_message "ERROR: Database backup appears empty: $db_name"
            return 1
        fi
    fi
}

backup_system() {
    local backup_name="$1"
    local backup_dir="$2"
    
    # System configuration backup
    tar -czf "$backup_dir/system_config.tar.gz" \
        /etc \
        /usr/local/etc \
        /var/spool/cron \
        --exclude=/etc/shadow \
        --exclude=/etc/gshadow
    
    # Installed packages list
    if command -v dpkg >/dev/null 2>&1; then
        dpkg --get-selections > "$backup_dir/installed_packages.txt"
    elif command -v rpm >/dev/null 2>&1; then
        rpm -qa > "$backup_dir/installed_packages.txt"
    fi
    
    # System information
    {
        echo "=== System Information ==="
        uname -a
        echo
        echo "=== Disk Usage ==="
        df -h
        echo
        echo "=== Network Configuration ==="
        ip addr show
        echo
        echo "=== Running Services ==="
        systemctl list-units --type=service --state=running
    } > "$backup_dir/system_info.txt"
}

compress_and_encrypt() {
    local backup_dir="$1"
    local backup_archive="${backup_dir}.tar.gz.gpg"
    
    # Create compressed archive
    tar -czf - -C "$(dirname "$backup_dir")" "$(basename "$backup_dir")" | \
    gpg --cipher-algo AES256 --compress-algo 1 --symmetric \
        --passphrase-file "$ENCRYPTION_KEY" \
        --output "$backup_archive"
    
    # Verify archive
    if [[ -f "$backup_archive" ]]; then
        # Test decryption
        if gpg --quiet --batch --decrypt \
            --passphrase-file "$ENCRYPTION_KEY" \
            "$backup_archive" | tar -tz >/dev/null 2>&1; then
            
            log_message "Backup archive verified: $backup_archive"
            rm -rf "$backup_dir"  # Remove uncompressed backup
        else
            log_message "ERROR: Backup archive verification failed"
            return 1
        fi
    fi
}

restore_backup() {
    local backup_name="$1"
    local backup_date="$2"
    local restore_path="$3"
    
    local backup_archive="$BACKUP_BASE_DIR/$backup_name/$backup_date.tar.gz.gpg"
    
    if [[ ! -f "$backup_archive" ]]; then
        echo "Backup archive not found: $backup_archive" >&2
        return 1
    fi
    
    # Create restore directory
    mkdir -p "$restore_path"
    
    # Decrypt and extract
    gpg --quiet --batch --decrypt \
        --passphrase-file "$ENCRYPTION_KEY" \
        "$backup_archive" | \
    tar -xz -C "$restore_path"
    
    log_message "Restore completed to: $restore_path"
}

log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}
```

### Performance Monitoring Dashboards

Performance monitoring dashboards provide real-time insights into system health, resource usage, and performance trends through automated data collection and visualization.

Create comprehensive system monitoring scripts:

```bash
#!/bin/bash
# System performance monitoring dashboard

DASHBOARD_DIR="/var/www/html/dashboard"
DATA_DIR="/var/lib/monitoring"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=85
ALERT_THRESHOLD_DISK=90

collect_system_metrics() {
    local timestamp=$(date +%s)
    local date_str=$(date '+%Y-%m-%d %H:%M:%S')
    
    # CPU metrics
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d% -f1)
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
    
    # Memory metrics
    local memory_info=$(free | grep Mem)
    local memory_total=$(echo "$memory_info" | awk '{print $2}')
    local memory_used=$(echo "$memory_info" | awk '{print $3}')
    local memory_percent=$(echo "scale=2; $memory_used * 100 / $memory_total" | bc)
    
    # Disk metrics
    local disk_info=$(df / | tail -1)
    local disk_usage=$(echo "$disk_info" | awk '{print $5}' | cut -d% -f1)
    
    # Network metrics
    local network_stats=$(cat /proc/net/dev | grep eth0 || cat /proc/net/dev | grep enp)
    local bytes_received=$(echo "$network_stats" | awk '{print $2}')
    local bytes_sent=$(echo "$network_stats" | awk '{print $10}')
    
    # Process metrics
    local process_count=$(ps aux | wc -l)
    local zombie_count=$(ps aux | awk '$8 ~ /^Z/ {count++} END {print count+0}')
    
    # Store metrics
    echo "$timestamp,$date_str,$cpu_usage,$load_avg,$memory_percent,$disk_usage,$bytes_received,$bytes_sent,$process_count,$zombie_count" \
        >> "$DATA_DIR/system_metrics.csv"
    
    # Check for alerts
    check_alerts "$cpu_usage" "$memory_percent" "$disk_usage"
}

collect_service_metrics() {
    local timestamp=$(date +%s)
    local services=("apache2" "mysql" "postgresql" "nginx" "ssh")
    
    for service in "${services[@]}"; do
        local status="down"
        local response_time="0"
        
        if systemctl is-active --quiet "$service"; then
            status="up"
            
            # Measure response time for web services
            case "$service" in
                "apache2"|"nginx")
                    response_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost/ 2>/dev/null || echo "0")
                    ;;
                "mysql")
                    response_time=$(time mysql -e "SELECT 1;" 2>&1 | grep real | awk '{print $2}' | cut -dm -f2 | cut -ds -f1)
                    ;;
            esac
        fi
        
        echo "$timestamp,$service,$status,$response_time" >> "$DATA_DIR/service_metrics.csv"
    done
}

generate_html_dashboard() {
    local dashboard_file="$DASHBOARD_DIR/index.html"
    
    cat > "$dashboard_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>System Performance Dashboard</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .dashboard { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .metric-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric-value { font-size: 2em; font-weight: bold; color: #333; }
        .metric-label { color: #666; margin-top: 5px; }
        .chart-container { width: 100%; height: 300px; margin: 20px 0; }
        .alert { background: #ffebee; border-left: 4px solid #f44336; padding: 10px; margin: 10px 0; }
        .status-up { color: #4caf50; }
        .status-down { color: #f44336; }
    </style>
</head>
<body>
    <h1>System Performance Dashboard</h1>
    <div id="lastUpdate"></div>
    
    <div class="dashboard">
        <div class="metric-card">
            <div class="metric-value" id="cpuUsage">--</div>
            <div class="metric-label">CPU Usage (%)</div>
        </div>
        
        <div class="metric-card">
            <div class="metric-value" id="memoryUsage">--</div>
            <div class="metric-label">Memory Usage (%)</div>
        </div>
        
        <div class="metric-card">
            <div class="metric-value" id="diskUsage">--</div>
            <div class="metric-label">Disk Usage (%)</div>
        </div>
        
        <div class="metric-card">
            <div class="metric-value" id="loadAvg">--</div>
            <div class="metric-label">Load Average</div>
        </div>
    </div>
    
    <div class="chart-container">
        <canvas id="cpuChart"></canvas>
    </div>
    
    <div class="chart-container">
        <canvas id="memoryChart"></canvas>
    </div>
    
    <div id="serviceStatus"></div>
    <div id="alerts"></div>
    
    <script>
        // Dashboard JavaScript code
        function updateDashboard() {
            fetch('/api/metrics')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('cpuUsage').textContent = data.cpu_usage;
                    document.getElementById('memoryUsage').textContent = data.memory_usage;
                    document.getElementById('diskUsage').textContent = data.disk_usage;
                    document.getElementById('loadAvg').textContent = data.load_avg;
                    document.getElementById('lastUpdate').textContent = 'Last updated: ' + new Date().toLocaleString();
                    
                    updateCharts(data.historical);
                    updateServiceStatus(data.services);
                    updateAlerts(data.alerts);
                });
        }
        
        // Update every 30 seconds
        setInterval(updateDashboard, 30000);
        updateDashboard();
    </script>
</body>
</html>
EOF
}

create_api_endpoint() {
    local api_script="$DASHBOARD_DIR/api/metrics"
    
    mkdir -p "$(dirname "$api_script")"
    
    cat > "$api_script" << 'EOF'
#!/bin/bash
echo "Content-Type: application/json"
echo ""

# Get latest metrics
latest_metrics=$(tail -1 /var/lib/monitoring/system_metrics.csv)
IFS=',' read -r timestamp date_str cpu_usage load_avg memory_percent disk_usage bytes_received bytes_sent process_count zombie_count <<< "$latest_metrics"

# Get historical data (last 24 hours)
historical_data=$(tail -144 /var/lib/monitoring/system_metrics.csv | jq -R 'split(",") | {timestamp: .[0], cpu: .[2], memory: .[4]}' | jq -s '.')

# Get service status
service_status=$(tail -20 /var/lib/monitoring/service_metrics.csv | jq -R 'split(",") | {service: .[1], status: .[2], response_time: .[3]}' | jq -s 'group_by(.service) | map({service: .[0].service, status: .[-1].status, response_time: .[-1].response_time})')

# Generate JSON response
cat << JSON
{
    "cpu_usage": $cpu_usage,
    "memory_usage": $memory_percent,
    "disk_usage": $disk_usage,
    "load_avg": $load_avg,
    "process_count": $process_count,
    "zombie_count": $zombie_count,
    "historical": $historical_data,
    "services": $service_status,
    "alerts": []
}
JSON
EOF
    
    chmod +x "$api_script"
}

check_alerts() {
    local cpu_usage="$1"
    local memory_usage="$2"
    local disk_usage="$3"
    local alert_file="$DATA_DIR/alerts.txt"
    
    # Clear previous alerts
    > "$alert_file"
    
    # Check CPU usage
    if (( $(echo "$cpu_usage > $ALERT_THRESHOLD_CPU" | bc -l) )); then
        echo "$(date): HIGH CPU USAGE - ${cpu_usage}%" >> "$alert_file"
    fi
    
    # Check memory usage
    if (( $(echo "$memory_usage > $ALERT_THRESHOLD_MEMORY" | bc -l) )); then
        echo "$(date): HIGH MEMORY USAGE - ${memory_usage}%" >> "$alert_file"
    fi
    
    # Check disk usage
    if (( disk_usage > ALERT_THRESHOLD_DISK )); then
        echo "$(date): HIGH DISK USAGE - ${disk_usage}%" >> "$alert_file"
    fi
    
    # Send alerts if any exist
    if [[ -s "$alert_file" ]]; then
        send_alert_notification "$alert_file"
    fi
}

send_alert_notification() {
    local alert_file="$1"
    local subject="System Alert - $(hostname)"
    
    # Send email alert
    if command -v mail >/dev/null 2>&1; then
        mail -s "$subject" admin@company.com < "$alert_file"
    fi
    
    # Send to monitoring system
    if command -v curl >/dev/null 2>&1; then
        curl -X POST -H "Content-Type: application/json" \
            -d "{\"alerts\": \"$(cat "$alert_file")\"}" \
            http://monitoring-system/api/alerts
    fi
}
```

**Key points** for system administration scripts include implementing proper error handling and logging, ensuring idempotent operations, maintaining security through proper permissions and credential management, and creating comprehensive monitoring and alerting systems that provide actionable insights into system health and performance.

---

