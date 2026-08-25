## Network Programming


### HTTP Requests with curl

curl is the Swiss Army knife of network programming in bash, providing comprehensive support for HTTP/HTTPS requests, authentication methods, and data transfer protocols. Understanding curl's extensive options enables you to interact with web services, APIs, and remote resources effectively.

Basic HTTP methods form the foundation of web communication. GET requests retrieve data from servers, POST requests send data to create resources, PUT requests update existing resources, and DELETE requests remove resources. curl supports all these methods through the `-X` option, with GET being the default.

Request headers control how servers interpret your requests. Common headers include `Content-Type` for specifying data format, `Authorization` for authentication, `User-Agent` for client identification, and custom headers for application-specific requirements. The `-H` option allows you to set multiple headers.

Authentication mechanisms vary across services. Basic authentication uses username and password combinations, while bearer tokens provide more secure access to modern APIs. OAuth2 flows require multiple requests to obtain access tokens. curl supports these through various authentication options.

Data handling capabilities include sending JSON payloads, form data, file uploads, and binary content. The `-d` option sends data in the request body, while `--data-urlencode` handles URL encoding automatically. For file uploads, use `-F` for multipart form data or `--upload-file` for direct file transfers.

Response handling involves capturing status codes, headers, and body content. The `-w` option provides detailed response information, while `-o` saves response bodies to files. Error handling uses `-f` to fail silently on HTTP errors and `--max-time` to prevent hanging requests.

**Example:**

```bash
#!/bin/bash

# HTTP request wrapper function
make_request() {
    local method=$1
    local url=$2
    local data=$3
    local headers=$4
    local output_file=$5
    
    local curl_opts=()
    
    # Set method
    [[ -n $method ]] && curl_opts+=(-X "$method")
    
    # Add headers
    if [[ -n $headers ]]; then
        while IFS= read -r header; do
            [[ -n $header ]] && curl_opts+=(-H "$header")
        done <<< "$headers"
    fi
    
    # Add data for POST/PUT requests
    [[ -n $data ]] && curl_opts+=(-d "$data")
    
    # Set output options
    [[ -n $output_file ]] && curl_opts+=(-o "$output_file")
    
    # Standard options for robust requests
    curl_opts+=(
        --silent                # No progress bar
        --show-error           # Show errors
        --fail                 # Exit on HTTP errors
        --location             # Follow redirects
        --max-time 30          # 30 second timeout
        --retry 3              # Retry on failure
        --retry-delay 1        # Wait between retries
        --write-out '%{http_code}:%{time_total}:%{size_download}\n'
    )
    
    # Execute request
    local response
    response=$(curl "${curl_opts[@]}" "$url" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$response"
        return 0
    else
        echo "curl failed with exit code $exit_code: $response" >&2
        return $exit_code
    fi
}

# REST API wrapper
api_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local token=$4
    
    local base_url="https://api.example.com/v1"
    local headers="Content-Type: application/json"
    
    # Add authentication if token provided
    if [[ -n $token ]]; then
        headers+=$'\n'"Authorization: Bearer $token"
    fi
    
    # Make request with error handling
    local response
    response=$(make_request "$method" "$base_url$endpoint" "$data" "$headers")
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Parse response info
        local http_code time_total size_download
        IFS=':' read -r http_code time_total size_download <<< "${response##*$'\n'}"
        
        # Log request details
        log INFO "API Request: $method $endpoint - HTTP $http_code - ${time_total}s - ${size_download} bytes"
        
        # Return just the response body
        echo "${response%$'\n'*}"
        return 0
    else
        log ERROR "API request failed: $method $endpoint"
        return $exit_code
    fi
}

# File upload with progress
upload_file() {
    local file_path=$1
    local upload_url=$2
    local field_name=${3:-file}
    
    if [[ ! -f $file_path ]]; then
        log ERROR "File not found: $file_path"
        return 1
    fi
    
    log INFO "Uploading file: $file_path"
    
    curl \
        --form "${field_name}=@${file_path}" \
        --progress-bar \
        --fail \
        --location \
        --max-time 300 \
        --write-out 'Upload completed: %{http_code} - %{time_total}s - %{speed_upload} bytes/s\n' \
        "$upload_url"
}

# Download with resume capability
download_file() {
    local url=$1
    local output_path=$2
    local max_attempts=${3:-3}
    
    local attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        log INFO "Download attempt $attempt of $max_attempts"
        
        if curl \
            --location \
            --fail \
            --continue-at - \
            --progress-bar \
            --max-time 600 \
            --output "$output_path" \
            "$url"; then
            log INFO "Download completed successfully"
            return 0
        else
            log WARN "Download attempt $attempt failed"
            ((attempt++))
            sleep 5
        fi
    done
    
    log ERROR "Download failed after $max_attempts attempts"
    return 1
}
```

### API Integration and JSON Parsing

JSON parsing in bash requires external tools since bash doesn't have native JSON support. The most common tools are `jq` for complex parsing, `python -m json.tool` for simple validation, and `grep`/`sed` for basic extraction, though jq is the recommended approach for robust JSON handling.

API authentication patterns vary significantly across services. RESTful APIs commonly use API keys in headers, OAuth2 bearer tokens, or basic authentication. GraphQL APIs typically use POST requests with query payloads. Understanding the authentication flow is crucial for successful API integration.

Data validation becomes critical when parsing API responses. Always validate JSON structure before attempting to extract values, handle missing fields gracefully, and implement type checking for extracted data. Use jq's error handling capabilities to catch malformed JSON responses.

Rate limiting and retry logic prevent API abuse and handle temporary failures. Implement exponential backoff for retries, respect rate limit headers, and cache responses when appropriate to reduce API calls.

Error handling for API responses should differentiate between client errors (4xx), server errors (5xx), and network errors. Each category requires different handling strategies, from user input validation to automatic retries.

**Example:**

```bash
#!/bin/bash

# JSON parser using jq
parse_json() {
    local json_data=$1
    local jq_query=$2
    local default_value=$3
    
    if [[ -z $json_data ]]; then
        echo "${default_value:-null}"
        return 1
    fi
    
    # Validate JSON first
    if ! echo "$json_data" | jq empty 2>/dev/null; then
        log ERROR "Invalid JSON data provided"
        echo "${default_value:-null}"
        return 1
    fi
    
    # Extract data with error handling
    local result
    result=$(echo "$json_data" | jq -r "$jq_query" 2>/dev/null)
    
    if [[ $? -eq 0 && $result != "null" ]]; then
        echo "$result"
        return 0
    else
        echo "${default_value:-null}"
        return 1
    fi
}

# GitHub API integration example
github_api() {
    local action=$1
    local repo=$2
    local token=$3
    shift 3
    local params=("$@")
    
    local base_url="https://api.github.com"
    local headers="Accept: application/vnd.github.v3+json"
    
    if [[ -n $token ]]; then
        headers+=$'\n'"Authorization: token $token"
    fi
    
    case $action in
        "get_repo")
            local response
            response=$(api_request "GET" "/repos/$repo" "" "$token")
            if [[ $? -eq 0 ]]; then
                # Parse repository information
                local name description stars forks
                name=$(parse_json "$response" '.name')
                description=$(parse_json "$response" '.description')
                stars=$(parse_json "$response" '.stargazers_count')
                forks=$(parse_json "$response" '.forks_count')
                
                echo "Repository: $name"
                echo "Description: $description"
                echo "Stars: $stars, Forks: $forks"
            fi
            ;;
        "list_issues")
            local state=${params[0]:-open}
            local response
            response=$(api_request "GET" "/repos/$repo/issues?state=$state" "" "$token")
            if [[ $? -eq 0 ]]; then
                # Parse issues list
                local issues_count
                issues_count=$(parse_json "$response" 'length')
                echo "Found $issues_count issues"
                
                # Extract issue details
                echo "$response" | jq -r '.[] | "Issue #\(.number): \(.title) (\(.state))"'
            fi
            ;;
        "create_issue")
            local title=${params[0]}
            local body=${params[1]}
            local issue_data
            issue_data=$(jq -n --arg title "$title" --arg body "$body" '{title: $title, body: $body}')
            
            local response
            response=$(api_request "POST" "/repos/$repo/issues" "$issue_data" "$token")
            if [[ $? -eq 0 ]]; then
                local issue_number
                issue_number=$(parse_json "$response" '.number')
                echo "Created issue #$issue_number"
            fi
            ;;
    esac
}

# Generic API client with pagination
api_client() {
    local base_url=$1
    local endpoint=$2
    local auth_token=$3
    local query_params=$4
    
    local all_data=()
    local page=1
    local per_page=50
    local has_more=true
    
    while [[ $has_more == true ]]; do
        log INFO "Fetching page $page"
        
        # Build URL with pagination
        local url="$base_url$endpoint"
        local separator="?"
        [[ $endpoint == *"?"* ]] && separator="&"
        
        if [[ -n $query_params ]]; then
            url+="$separator$query_params&page=$page&per_page=$per_page"
        else
            url+="${separator}page=$page&per_page=$per_page"
        fi
        
        # Make request
        local response
        response=$(make_request "GET" "$url" "" "Authorization: Bearer $auth_token")
        
        if [[ $? -eq 0 ]]; then
            # Parse response body (remove curl stats)
            local body="${response%$'\n'*}"
            
            # Check if we have data
            local items_count
            items_count=$(parse_json "$body" 'length')
            
            if [[ $items_count -gt 0 ]]; then
                all_data+=("$body")
                ((page++))
                
                # Check if we have more pages
                if [[ $items_count -lt $per_page ]]; then
                    has_more=false
                fi
            else
                has_more=false
            fi
        else
            log ERROR "Failed to fetch page $page"
            return 1
        fi
    done
    
    # Combine all pages
    if [[ ${#all_data[@]} -gt 0 ]]; then
        echo "${all_data[@]}" | jq -s 'add'
    else
        echo "[]"
    fi
}

# Configuration management for API clients
load_api_config() {
    local config_file=${1:-~/.api_config}
    
    if [[ ! -f $config_file ]]; then
        log ERROR "Configuration file not found: $config_file"
        return 1
    fi
    
    # Load configuration safely
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue
        
        # Export as environment variable
        export "API_${key^^}"="$value"
    done < "$config_file"
    
    log INFO "API configuration loaded from $config_file"
}
```

### Network Monitoring Scripts

Network monitoring scripts provide real-time visibility into network performance, connectivity issues, and service availability. These scripts can detect problems early, collect performance metrics, and trigger alerts when thresholds are exceeded.

Connectivity monitoring checks basic network reachability using ping, traceroute, and port scanning. Monitor critical services by checking specific ports, measure response times, and detect network path changes. Implement both IPv4 and IPv6 monitoring where applicable.

Service health monitoring extends beyond basic connectivity to check application-specific endpoints. HTTP health checks verify web services, database connections test backend services, and API endpoint monitoring ensures service functionality.

Performance metrics collection involves measuring latency, throughput, packet loss, and jitter. Historical data collection enables trend analysis and capacity planning. Use tools like iperf for bandwidth testing and netstat for connection monitoring.

Alert mechanisms should provide immediate notification of issues while avoiding alert fatigue. Implement threshold-based alerts, escalation procedures, and recovery notifications. Consider different alert channels for different severity levels.

**Example:**

```bash
#!/bin/bash

# Network connectivity monitor
monitor_connectivity() {
    local targets_file=${1:-/etc/monitoring/targets.txt}
    local report_file=${2:-/var/log/connectivity_monitor.log}
    
    # Read monitoring targets
    if [[ ! -f $targets_file ]]; then
        log ERROR "Targets file not found: $targets_file"
        return 1
    fi
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "=== Connectivity Monitor Report - $timestamp ===" >> "$report_file"
    
    while IFS=':' read -r host port description; do
        # Skip comments and empty lines
        [[ $host =~ ^[[:space:]]*# ]] && continue
        [[ -z $host ]] && continue
        
        local status="OK"
        local response_time=""
        
        if [[ -n $port ]]; then
            # Port-specific check
            if check_port "$host" "$port"; then
                response_time=$(measure_response_time "$host" "$port")
                status="OK ($response_time ms)"
            else
                status="FAILED"
            fi
        else
            # Basic ping check
            if ping -c 1 -W 5 "$host" &>/dev/null; then
                response_time=$(ping -c 1 -W 5 "$host" | grep 'time=' | cut -d'=' -f4)
                status="OK ($response_time)"
            else
                status="FAILED"
            fi
        fi
        
        local log_entry="$timestamp $host:$port $status $description"
        echo "$log_entry" >> "$report_file"
        
        # Alert on failure
        if [[ $status == "FAILED" ]]; then
            send_alert "CONNECTIVITY" "$host:$port" "$description"
        fi
        
    done < "$targets_file"
}

# Port checker with timeout
check_port() {
    local host=$1
    local port=$2
    local timeout=${3:-5}
    
    # Use different methods based on availability
    if command -v nc &>/dev/null; then
        # Using netcat
        nc -z -w "$timeout" "$host" "$port" &>/dev/null
    elif command -v timeout &>/dev/null; then
        # Using timeout with bash TCP redirect
        timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" &>/dev/null
    else
        # Fallback to telnet
        timeout "$timeout" telnet "$host" "$port" &>/dev/null
    fi
}

# Response time measurement
measure_response_time() {
    local host=$1
    local port=$2
    
    local start_time end_time
    start_time=$(date +%s%N)
    
    if check_port "$host" "$port"; then
        end_time=$(date +%s%N)
        echo $(( (end_time - start_time) / 1000000 ))
    else
        echo "timeout"
    fi
}

# Service health monitor
monitor_services() {
    local services_config=${1:-/etc/monitoring/services.yaml}
    
    # Parse service configurations
    while IFS= read -r line; do
        case $line in
            *"name:"*)
                service_name=$(echo "$line" | cut -d':' -f2 | xargs)
                ;;
            *"url:"*)
                service_url=$(echo "$line" | cut -d':' -f2- | xargs)
                ;;
            *"method:"*)
                method=$(echo "$line" | cut -d':' -f2 | xargs)
                ;;
            *"expected_code:"*)
                expected_code=$(echo "$line" | cut -d':' -f2 | xargs)
                ;;
            *"timeout:"*)
                timeout=$(echo "$line" | cut -d':' -f2 | xargs)
                ;;
            *"---"*)
                # End of service definition, check service
                if [[ -n $service_name && -n $service_url ]]; then
                    check_service_health "$service_name" "$service_url" "$method" "$expected_code" "$timeout"
                fi
                
                # Reset variables
                service_name=""
                service_url=""
                method="GET"
                expected_code="200"
                timeout="10"
                ;;
        esac
    done < "$services_config"
}

# Individual service health check
check_service_health() {
    local name=$1
    local url=$2
    local method=${3:-GET}
    local expected_code=${4:-200}
    local timeout=${5:-10}
    
    log INFO "Checking service: $name"
    
    # Make request and capture response
    local response
    response=$(curl \
        --silent \
        --write-out '%{http_code}:%{time_total}:%{size_download}' \
        --max-time "$timeout" \
        --request "$method" \
        "$url" 2>/dev/null)
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Parse response
        local body="${response%:*:*}"
        local stats="${response##*$'\n'}"
        local http_code time_total size_download
        IFS=':' read -r http_code time_total size_download <<< "$stats"
        
        # Check status
        if [[ $http_code -eq $expected_code ]]; then
            log INFO "Service $name: OK (${http_code}, ${time_total}s, ${size_download} bytes)"
            update_service_status "$name" "OK" "$http_code" "$time_total"
        else
            log ERROR "Service $name: HTTP $http_code (expected $expected_code)"
            send_alert "SERVICE" "$name" "HTTP $http_code returned, expected $expected_code"
            update_service_status "$name" "ERROR" "$http_code" "$time_total"
        fi
    else
        log ERROR "Service $name: Connection failed"
        send_alert "SERVICE" "$name" "Connection timeout or failure"
        update_service_status "$name" "FAILED" "000" "timeout"
    fi
}

# Network performance monitoring
monitor_network_performance() {
    local interface=${1:-eth0}
    local duration=${2:-60}
    
    log INFO "Monitoring network performance on $interface for ${duration}s"
    
    # Initial measurements
    local start_rx start_tx
    read start_rx start_tx < <(get_interface_stats "$interface")
    local start_time=$(date +%s)
    
    sleep "$duration"
    
    # Final measurements
    local end_rx end_tx
    read end_rx end_tx < <(get_interface_stats "$interface")
    local end_time=$(date +%s)
    
    # Calculate throughput
    local duration_actual=$((end_time - start_time))
    local rx_bytes=$((end_rx - start_rx))
    local tx_bytes=$((end_tx - start_tx))
    
    local rx_mbps=$(( (rx_bytes * 8) / (duration_actual * 1024 * 1024) ))
    local tx_mbps=$(( (tx_bytes * 8) / (duration_actual * 1024 * 1024) ))
    
    log INFO "Network Performance - RX: ${rx_mbps} Mbps, TX: ${tx_mbps} Mbps"
    
    # Store metrics
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp,$interface,$rx_mbps,$tx_mbps" >> /var/log/network_performance.csv
    
    # Check thresholds
    if [[ $rx_mbps -gt 80 || $tx_mbps -gt 80 ]]; then
        send_alert "PERFORMANCE" "$interface" "High network utilization: RX=${rx_mbps}Mbps, TX=${tx_mbps}Mbps"
    fi
}

# Get interface statistics
get_interface_stats() {
    local interface=$1
    local rx_bytes tx_bytes
    
    if [[ -f "/sys/class/net/$interface/statistics/rx_bytes" ]]; then
        rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes")
        tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes")
    else
        # Fallback to ifconfig
        local stats
        stats=$(ifconfig "$interface" 2>/dev/null | grep -E "RX bytes|TX bytes")
        rx_bytes=$(echo "$stats" | grep "RX bytes" | cut -d':' -f2 | cut -d' ' -f1)
        tx_bytes=$(echo "$stats" | grep "TX bytes" | cut -d':' -f2 | cut -d' ' -f1)
    fi
    
    echo "$rx_bytes $tx_bytes"
}

# Alert sender
send_alert() {
    local type=$1
    local target=$2
    local message=$3
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local alert_message="[$timestamp] $type ALERT: $target - $message"
    
    # Log alert
    log ERROR "$alert_message"
    
    # Send to various channels
    if [[ -n $SLACK_WEBHOOK ]]; then
        curl -s -X POST \
            -H 'Content-type: application/json' \
            --data "{\"text\":\"$alert_message\"}" \
            "$SLACK_WEBHOOK"
    fi
    
    if [[ -n $EMAIL_RECIPIENT ]]; then
        echo "$alert_message" | mail -s "Network Alert: $type" "$EMAIL_RECIPIENT"
    fi
    
    # Write to alert log
    echo "$alert_message" >> /var/log/network_alerts.log
}
```

### Remote Script Execution

Remote script execution enables centralized management and automation across multiple systems. This involves secure script distribution, remote command execution, and result collection from distributed systems.

SSH-based execution provides secure remote command execution with proper authentication and encryption. Key-based authentication eliminates password requirements, while SSH agent forwarding enables multi-hop connections. Connection multiplexing reduces overhead for multiple commands.

Script distribution mechanisms include SCP for simple file transfers, rsync for efficient synchronization, and configuration management tools for complex deployments. Version control integration ensures script consistency across environments.

Parallel execution capabilities allow simultaneous operations across multiple hosts. This requires careful resource management, error handling, and result aggregation. Tools like GNU parallel or custom bash solutions can coordinate parallel operations.

Security considerations include proper key management, network isolation, privilege escalation controls, and audit logging. Implement least-privilege access and validate all remote inputs to prevent security issues.

**Example:**

```bash
#!/bin/bash

# SSH connection manager
ssh_manager() {
    local action=$1
    local host=$2
    shift 2
    local args=("$@")
    
    # SSH configuration
    local ssh_config="/etc/ssh/ssh_config"
    local ssh_key="${HOME}/.ssh/id_rsa"
    local ssh_user="${SSH_USER:-root}"
    local ssh_port="${SSH_PORT:-22}"
    
    # Build SSH command
    local ssh_opts=(
        -o "StrictHostKeyChecking=no"
        -o "UserKnownHostsFile=/dev/null"
        -o "ConnectTimeout=10"
        -o "ServerAliveInterval=60"
        -o "ServerAliveCountMax=3"
        -i "$ssh_key"
        -p "$ssh_port"
    )
    
    case $action in
        "execute")
            local command="${args[0]}"
            log INFO "Executing on $host: $command"
            
            ssh "${ssh_opts[@]}" "${ssh_user}@${host}" "$command"
            ;;
        "copy")
            local source="${args[0]}"
            local destination="${args[1]}"
            log INFO "Copying $source to $host:$destination"
            
            scp "${ssh_opts[@]}" "$source" "${ssh_user}@${host}:${destination}"
            ;;
        "sync")
            local source="${args[0]}"
            local destination="${args[1]}"
            log INFO "Syncing $source to $host:$destination"
            
            rsync -avz -e "ssh ${ssh_opts[*]}" "$source" "${ssh_user}@${host}:${destination}"
            ;;
        "tunnel")
            local local_port="${args[0]}"
            local remote_port="${args[1]}"
            log INFO "Creating tunnel $local_port -> $host:$remote_port"
            
            ssh "${ssh_opts[@]}" -L "${local_port}:localhost:${remote_port}" -N "${ssh_user}@${host}"
            ;;
    esac
}

# Parallel remote execution
parallel_execute() {
    local script_path=$1
    local hosts_file=$2
    local max_concurrent=${3:-5}
    
    if [[ ! -f $script_path ]]; then
        log ERROR "Script not found: $script_path"
        return 1
    fi
    
    if [[ ! -f $hosts_file ]]; then
        log ERROR "Hosts file not found: $hosts_file"
        return 1
    fi
    
    # Create temporary directory for results
    local temp_dir=$(mktemp -d)
    local job_pids=()
    
    log INFO "Starting parallel execution across $(wc -l < "$hosts_file") hosts"
    
    # Execute on each host
    while IFS= read -r host; do
        # Skip comments and empty lines
        [[ $host =~ ^[[:space:]]*# ]] && continue
        [[ -z $host ]] && continue
        
        # Wait if we've reached max concurrent jobs
        while [[ ${#job_pids[@]} -ge $max_concurrent ]]; do
            wait_for_job_completion job_pids
        done
        
        # Start job in background
        execute_on_host "$host" "$script_path" "$temp_dir" &
        job_pids+=($!)
        
        log INFO "Started job for $host (PID: $!)"
    done < "$hosts_file"
    
    # Wait for all jobs to complete
    log INFO "Waiting for all jobs to complete..."
    for pid in "${job_pids[@]}"; do
        wait "$pid"
    done
    
    # Collect and summarize results
    summarize_results "$temp_dir"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Execute script on individual host
execute_on_host() {
    local host=$1
    local script_path=$2
    local results_dir=$3
    
    local start_time=$(date +%s)
    local result_file="$results_dir/${host}.result"
    
    # Copy script to remote host
    local remote_script="/tmp/$(basename "$script_path")"
    if ssh_manager "copy" "$host" "$script_path" "$remote_script"; then
        log INFO "Script copied to $host"
        
        # Execute script and capture output
        {
            echo "=== Execution on $host started at $(date) ==="
            if ssh_manager "execute" "$host" "chmod +x $remote_script && $remote_script"; then
                echo "=== Execution completed successfully ==="
                echo "EXIT_CODE:0"
            else
                echo "=== Execution failed ==="
                echo "EXIT_CODE:$?"
            fi
            echo "=== Execution finished at $(date) ==="
        } > "$result_file" 2>&1
        
        # Cleanup remote script
        ssh_manager "execute" "$host" "rm -f $remote_script" &>/dev/null
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo "DURATION:$duration" >> "$result_file"
        
        log INFO "Execution on $host completed in ${duration}s"
    else
        log ERROR "Failed to copy script to $host"
        echo "COPY_FAILED" > "$result_file"
    fi
}

# Wait for job completion
wait_for_job_completion() {
    local -n pids_ref=$1
    local completed_pids=()
    
    for i in "${!pids_ref[@]}"; do
        local pid="${pids_ref[i]}"
        if ! kill -0 "$pid" 2>/dev/null; then
            completed_pids+=("$i")
        fi
    done
    
    # Remove completed jobs from array
    for i in "${completed_pids[@]}"; do
        unset "pids_ref[i]"
    done
    
    # Rebuild array to remove gaps
    local new_pids=()
    for pid in "${pids_ref[@]}"; do
        new_pids+=("$pid")
    done
    pids_ref=("${new_pids[@]}")
    
    # Sleep briefly if no jobs completed
    if [[ ${#completed_pids[@]} -eq 0 ]]; then
        sleep 1
    fi
}

# Summarize execution results
summarize_results() {
    local results_dir=$1
    
    local total_hosts=0
    local successful_hosts=0
    local failed_hosts=0
    local total_duration=0
    
    echo "=== Execution Summary ==="
    echo "$(date '+%Y-%m-%d %H:%M:%S')"
    echo
    
    for result_file in "$results_dir"/*.result; do
        [[ ! -f $result_file ]] && continue
        
        local host=$(basename "$result_file" .result)
        ((total_hosts++))
        
        if grep -q "EXIT_CODE:0" "$result_file"; then
            ((successful_hosts++))
            echo "✓ $host: SUCCESS"
        else
            ((failed_hosts++))
            echo "✗ $host: FAILED"
            
            # Show error details
            echo "  Error details:"
            tail -n 5 "$result_file" | sed 's/^/    /'
        fi
        
        # Add duration if available
        local duration
        duration=$(grep "DURATION:" "$result_file" | cut -d':' -f2)
        if [[ -n $duration ]]; then
            total_duration=$((total_duration + duration))
            echo "  Duration: ${duration}s"
        fi
        
        echo
    done
    
    echo "=== Summary ==="
    echo "Total hosts: $total_hosts"
    echo "Successful: $successful_hosts"
    echo "Failed: $failed_hosts"
    echo "Success rate: $(( (successful_hosts * 100) / total_hosts ))%"
    echo "Total execution time: ${total_duration}s"
    echo "Average execution time: $(( total_duration / total_hosts ))s"
    
    # Generate detailed report
    local report_file="/var/log/remote_execution_$(date +%Y%m%d_%H%M%S).log"
    {
        echo "=== Detailed Execution Report ==="
        echo "Generated: $(date)"
        echo "Total hosts: $total_hosts"
        echo "Successful: $successful_hosts"
        echo "Failed: $failed_hosts"
        echo
        
        for result_file in "$results_dir"/*.result; do
            [[ ! -f $result_file ]] && continue
            echo "=== $(basename "$result_file" .result) ==="
            cat "$result_file"
            echo
        done
    } > "$report_file"
    
    log INFO "Detailed report saved to: $report_file"
}

# Configuration deployment system
deploy_configuration() {
    local config_dir=$1
    local target_hosts=$2
    local deployment_strategy=${3:-rolling}
    
    if [[ ! -d $config_dir ]]; then
        log ERROR "Configuration directory not found: $config_dir"
        return 1
    fi
    
    # Validate configuration files
    log INFO "Validating configuration files..."
    if ! validate_configurations "$config_dir"; then
        log ERROR "Configuration validation failed"
        return 1
    fi
    
    # Create deployment package
    local package_file="/tmp/config_deployment_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$package_file" -C "$config_dir" .
    
    log INFO "Configuration package created: $package_file"
    
    case $deployment_strategy in
        "rolling")
            deploy_rolling "$package_file" "$target_hosts"
            ;;
        "parallel")
            deploy_parallel "$package_file" "$target_hosts"
            ;;
        "blue_green")
            deploy_blue_green "$package_file" "$target_hosts"
            ;;
        *)
            log ERROR "Unknown deployment strategy: $deployment_strategy"
            return 1
            ;;
    esac
    
    # Cleanup
    rm -f "$package_file"
}

# Rolling deployment
deploy_rolling() {
    local package_file=$1
    local hosts_file=$2
    local batch_size=${3:-1}
    
    log INFO "Starting rolling deployment with batch size: $batch_size"
    
    local hosts=()
    while IFS= read -r host; do
        [[ $host =~ ^[[:space:]]*# ]] && continue
        [[ -z $host ]] && continue
        hosts+=("$host")
    done < "$hosts_file"
    
    local total_hosts=${#hosts[@]}
    local current_batch=0
    
    for ((i=0; i<total_hosts; i+=batch_size)); do
        ((current_batch++))
        local batch_hosts=("${hosts[@]:i:batch_size}")
        
        log INFO "Deploying batch $current_batch (${#batch_hosts[@]} hosts)"
        
        # Deploy to current batch
        local batch_success=true
        for host in "${batch_hosts[@]}"; do
            if ! deploy_to_host "$host" "$package_file"; then
                log ERROR "Deployment failed on $host"
                batch_success=false
            fi
        done
        
        # Verify deployment
        if [[ $batch_success == true ]]; then
            log INFO "Batch $current_batch deployed successfully"
            
            # Health check delay
            log INFO "Waiting for services to stabilize..."
            sleep 30
            
            # Verify all hosts in batch are healthy
            for host in "${batch_hosts[@]}"; do
                if ! verify_deployment "$host"; then
                    log ERROR "Health check failed on $host"
                    batch_success=false
                fi
            done
        fi
        
        if [[ $batch_success == false ]]; then
            log ERROR "Rolling deployment failed at batch $current_batch"
            return 1
        fi
    done
    
    log INFO "Rolling deployment completed successfully"
}

# Deploy to individual host
deploy_to_host() {
    local host=$1
    local package_file=$2
    
    log INFO "Deploying to $host"
    
    # Copy package to remote host
    local remote_package="/tmp/$(basename "$package_file")"
    if ! ssh_manager "copy" "$host" "$package_file" "$remote_package"; then
        log ERROR "Failed to copy package to $host"
        return 1
    fi
    
    # Create deployment script
    local deploy_script=$(mktemp)
    cat > "$deploy_script" << 'EOF'
#!/bin/bash

set -e

PACKAGE_FILE="$1"
BACKUP_DIR="/opt/config_backup/$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="/etc/myapp"

# Create backup
mkdir -p "$BACKUP_DIR"
if [[ -d "$CONFIG_DIR" ]]; then
    cp -r "$CONFIG_DIR" "$BACKUP_DIR/"
fi

# Extract new configuration
mkdir -p "$CONFIG_DIR"
cd "$CONFIG_DIR"
tar -xzf "$PACKAGE_FILE"

# Set permissions
chown -R myapp:myapp "$CONFIG_DIR"
chmod -R 640 "$CONFIG_DIR"

# Restart services
systemctl restart myapp
systemctl restart nginx

# Verify services are running
sleep 5
systemctl is-active myapp
systemctl is-active nginx

echo "Deployment completed successfully"
EOF

    # Execute deployment
    local remote_script="/tmp/deploy_$(date +%s).sh"
    if ssh_manager "copy" "$host" "$deploy_script" "$remote_script"; then
        if ssh_manager "execute" "$host" "chmod +x $remote_script && $remote_script $remote_package"; then
            log INFO "Deployment successful on $host"
            
            # Cleanup
            ssh_manager "execute" "$host" "rm -f $remote_package $remote_script" &>/dev/null
            rm -f "$deploy_script"
            return 0
        else
            log ERROR "Deployment script failed on $host"
        fi
    else
        log ERROR "Failed to copy deployment script to $host"
    fi
    
    # Cleanup on failure
    ssh_manager "execute" "$host" "rm -f $remote_package $remote_script" &>/dev/null
    rm -f "$deploy_script"
    return 1
}

# Verify deployment
verify_deployment() {
    local host=$1
    
    log INFO "Verifying deployment on $host"
    
    # Check service status
    if ! ssh_manager "execute" "$host" "systemctl is-active myapp >/dev/null"; then
        log ERROR "Service verification failed on $host"
        return 1
    fi
    
    # Check configuration
    if ! ssh_manager "execute" "$host" "test -f /etc/myapp/app.conf"; then
        log ERROR "Configuration verification failed on $host"
        return 1
    fi
    
    # Check application health endpoint
    if ! ssh_manager "execute" "$host" "curl -sf http://localhost:8080/health >/dev/null"; then
        log ERROR "Health check failed on $host"
        return 1
    fi
    
    log INFO "Deployment verification successful on $host"
    return 0
}

# Remote log collection
collect_logs() {
    local hosts_file=$1
    local log_pattern=$2
    local time_range=$3
    local output_dir=${4:-/tmp/log_collection}
    
    mkdir -p "$output_dir"
    
    log INFO "Collecting logs from $(wc -l < "$hosts_file") hosts"
    
    while IFS= read -r host; do
        [[ $host =~ ^[[:space:]]*# ]] && continue
        [[ -z $host ]] && continue
        
        log INFO "Collecting logs from $host"
        
        local host_dir="$output_dir/$host"
        mkdir -p "$host_dir"
        
        # Build log collection command
        local log_cmd="find /var/log -name '$log_pattern' -type f"
        
        if [[ -n $time_range ]]; then
            log_cmd+=" -newermt '$time_range'"
        fi
        
        # Get list of log files
        local log_files
        log_files=$(ssh_manager "execute" "$host" "$log_cmd" 2>/dev/null)
        
        if [[ -n $log_files ]]; then
            # Copy each log file
            while IFS= read -r log_file; do
                local filename=$(basename "$log_file")
                local local_file="$host_dir/${filename}"
                
                if ssh_manager "copy" "$host" "$log_file" "$local_file"; then
                    log INFO "Collected: $host:$log_file"
                else
                    log WARN "Failed to collect: $host:$log_file"
                fi
            done <<< "$log_files"
        else
            log WARN "No matching log files found on $host"
        fi
        
    done < "$hosts_file"
    
    # Create summary
    local summary_file="$output_dir/collection_summary.txt"
    {
        echo "Log Collection Summary"
        echo "====================="
        echo "Collection time: $(date)"
        echo "Log pattern: $log_pattern"
        echo "Time range: $time_range"
        echo
        echo "Collected files:"
        find "$output_dir" -type f -name "*.log" | sort
        echo
        echo "Total files: $(find "$output_dir" -type f -name "*.log" | wc -l)"
        echo "Total size: $(du -sh "$output_dir" | cut -f1)"
    } > "$summary_file"
    
    log INFO "Log collection completed. Summary: $summary_file"
}

# Connection pooling for SSH
setup_ssh_pool() {
    local hosts_file=$1
    local pool_size=${2:-5}
    
    # Create SSH connection pool
    while IFS= read -r host; do
        [[ $host =~ ^[[:space:]]*# ]] && continue
        [[ -z $host ]] && continue
        
        # Create persistent connection
        ssh -o "ControlMaster=yes" \
            -o "ControlPath=~/.ssh/control-%r@%h:%p" \
            -o "ControlPersist=300" \
            -N "$host" &
        
        log INFO "Created SSH connection pool for $host"
    done < "$hosts_file"
}

# Cleanup SSH pool
cleanup_ssh_pool() {
    # Close all persistent connections
    ssh -O exit -o "ControlPath=~/.ssh/control-%r@%h:%p" "*" 2>/dev/null || true
    log INFO "SSH connection pool cleaned up"
}
```

**Key points** for effective network programming in bash include mastering curl's extensive options for robust HTTP communication, implementing proper JSON parsing with jq for reliable API integration, developing comprehensive network monitoring scripts that track both connectivity and performance metrics, and creating secure remote execution frameworks with proper error handling and parallel processing capabilities. Always implement proper authentication mechanisms, use connection pooling for improved performance, establish comprehensive logging and alerting systems, and ensure all network operations include appropriate timeout and retry logic to handle transient failures gracefully.

---

