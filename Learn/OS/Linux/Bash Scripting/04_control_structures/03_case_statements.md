## Case Statements


### Switch-Case Alternatives

Case statements in bash provide a clean alternative to multiple if-elif-else chains, offering better readability and performance when dealing with multiple conditions.

Basic case statement syntax:

```bash
case "$variable" in
    pattern1)
        # commands
        ;;
    pattern2)
        # commands
        ;;
    *)
        # default case
        ;;
esac
```

Comparing case statements to if-elif chains:

```bash
# Using if-elif (verbose and repetitive)
if [[ "$action" == "start" ]]; then
    echo "Starting service..."
elif [[ "$action" == "stop" ]]; then
    echo "Stopping service..."
elif [[ "$action" == "restart" ]]; then
    echo "Restarting service..."
elif [[ "$action" == "status" ]]; then
    echo "Checking status..."
else
    echo "Unknown action: $action"
fi

# Using case statement (cleaner)
case "$action" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    status)
        echo "Checking status..."
        ;;
    *)
        echo "Unknown action: $action"
        ;;
esac
```

Multiple patterns can be combined using pipe separators:

```bash
case "$response" in
    y|Y|yes|Yes|YES)
        echo "Proceeding with operation..."
        ;;
    n|N|no|No|NO)
        echo "Operation cancelled"
        ;;
    *)
        echo "Please answer yes or no"
        ;;
esac
```

Case statements with functions for complex logic:

```bash
handle_database_action() {
    case "$1" in
        backup)
            echo "Creating database backup..."
            pg_dump mydb > backup_$(date +%Y%m%d).sql
            ;;
        restore)
            echo "Restoring database..."
            psql mydb < "$2"
            ;;
        vacuum)
            echo "Vacuuming database..."
            psql -c "VACUUM ANALYZE;" mydb
            ;;
        *)
            echo "Usage: $0 {backup|restore <file>|vacuum}"
            return 1
            ;;
    esac
}
```

### Pattern Matching in Case Statements

Bash case statements support powerful pattern matching using wildcards, character classes, and ranges.

Wildcard patterns:

```bash
case "$filename" in
    *.txt)
        echo "Text file detected"
        ;;
    *.log)
        echo "Log file detected"
        ;;
    *.tar.gz|*.tgz)
        echo "Compressed archive detected"
        ;;
    backup_*)
        echo "Backup file detected"
        ;;
    *)
        echo "Unknown file type"
        ;;
esac
```

Character class patterns:

```bash
case "$input" in
    [0-9])
        echo "Single digit"
        ;;
    [0-9][0-9])
        echo "Two digits"
        ;;
    [a-zA-Z])
        echo "Single letter"
        ;;
    [a-zA-Z]*)
        echo "Starts with letter"
        ;;
    *[0-9])
        echo "Ends with digit"
        ;;
    *)
        echo "Other pattern"
        ;;
esac
```

Advanced pattern matching with extended globbing:

```bash
# Enable extended globbing
shopt -s extglob

case "$filename" in
    *.@(jpg|jpeg|png|gif))
        echo "Image file"
        ;;
    *.@(mp4|avi|mkv|mov))
        echo "Video file"
        ;;
    *.@(mp3|wav|flac|ogg))
        echo "Audio file"
        ;;
    +([0-9]).txt)
        echo "Numbered text file"
        ;;
    !(*.tmp|*.bak))
        echo "Not a temporary or backup file"
        ;;
    *)
        echo "Unknown file type"
        ;;
esac
```

Pattern matching with length and format validation:

```bash
validate_input() {
    local input="$1"
    
    case "$input" in
        [0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9])
            echo "Valid phone number format: XXX-XX-XXXX"
            ;;
        [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z][a-zA-Z])
            echo "Valid email format"
            ;;
        [0-9][0-9][0-9].[0-9][0-9][0-9].[0-9][0-9][0-9].[0-9][0-9][0-9])
            echo "Valid IP address format"
            ;;
        [A-Z][A-Z][0-9][0-9][0-9][0-9])
            echo "Valid product code format"
            ;;
        *)
            echo "Invalid format"
            return 1
            ;;
    esac
}
```

URL and protocol handling:

```bash
handle_url() {
    local url="$1"
    
    case "$url" in
        http://*)
            echo "HTTP URL detected"
            curl -s "$url" | head -n 10
            ;;
        https://*)
            echo "HTTPS URL detected"
            curl -s "$url" | head -n 10
            ;;
        ftp://*)
            echo "FTP URL detected"
            wget -q -O - "$url"
            ;;
        file://*)
            echo "Local file URL detected"
            local filepath="${url#file://}"
            cat "$filepath"
            ;;
        *)
            echo "Unknown or unsupported URL format"
            return 1
            ;;
    esac
}
```

### Menu Systems Using Case

Interactive menu systems provide user-friendly interfaces for script operations.

Basic menu loop:

```bash
show_menu() {
    echo "=== System Administration ==="
    echo "1. View system information"
    echo "2. Check disk usage"
    echo "3. Monitor processes"
    echo "4. View network connections"
    echo "5. Exit"
    echo -n "Enter your choice [1-5]: "
}

while true; do
    show_menu
    read -r choice
    
    case "$choice" in
        1)
            echo "System Information:"
            uname -a
            uptime
            ;;
        2)
            echo "Disk Usage:"
            df -h
            ;;
        3)
            echo "Top Processes:"
            ps aux --sort=-%cpu | head -10
            ;;
        4)
            echo "Network Connections:"
            netstat -tuln
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
    clear
done
```

Advanced menu with submenus:

```bash
#!/bin/bash

declare -A menu_stack=()
declare -i menu_level=0

push_menu() {
    menu_stack[$menu_level]="$1"
    ((menu_level++))
}

pop_menu() {
    ((menu_level--))
    [[ $menu_level -lt 0 ]] && menu_level=0
}

show_main_menu() {
    clear
    echo "=== Main Menu ==="
    echo "1. File Operations"
    echo "2. System Tools"
    echo "3. Network Tools"
    echo "4. Exit"
    echo -n "Choice: "
}

show_file_menu() {
    clear
    echo "=== File Operations ==="
    echo "1. List directory contents"
    echo "2. Search files"
    echo "3. File permissions"
    echo "4. Back to main menu"
    echo -n "Choice: "
}

show_system_menu() {
    clear
    echo "=== System Tools ==="
    echo "1. Process management"
    echo "2. Memory usage"
    echo "3. System logs"
    echo "4. Back to main menu"
    echo -n "Choice: "
}

handle_file_operations() {
    local choice="$1"
    
    case "$choice" in
        1)
            echo "Current directory contents:"
            ls -la
            ;;
        2)
            echo -n "Enter search pattern: "
            read -r pattern
            find . -name "*$pattern*" -type f
            ;;
        3)
            echo -n "Enter file path: "
            read -r filepath
            [[ -f "$filepath" ]] && ls -l "$filepath" || echo "File not found"
            ;;
        4)
            pop_menu
            return 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
    
    read -p "Press Enter to continue..."
    return 1
}

handle_system_tools() {
    local choice="$1"
    
    case "$choice" in
        1)
            echo "Top 10 processes by CPU usage:"
            ps aux --sort=-%cpu | head -11
            ;;
        2)
            echo "Memory usage:"
            free -h
            ;;
        3)
            echo "Recent system logs:"
            tail -20 /var/log/syslog 2>/dev/null || echo "Cannot access system logs"
            ;;
        4)
            pop_menu
            return 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
    
    read -p "Press Enter to continue..."
    return 1
}

main_menu_loop() {
    while true; do
        show_main_menu
        read -r choice
        
        case "$choice" in
            1)
                push_menu "file"
                while true; do
                    show_file_menu
                    read -r subchoice
                    handle_file_operations "$subchoice" && break
                done
                ;;
            2)
                push_menu "system"
                while true; do
                    show_system_menu
                    read -r subchoice
                    handle_system_tools "$subchoice" && break
                done
                ;;
            3)
                echo "Network tools not implemented yet"
                read -p "Press Enter to continue..."
                ;;
            4)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Start the application
main_menu_loop
```

Configuration-driven menu system:

```bash
#!/bin/bash

declare -A menu_config=(
    ["main_title"]="System Administration Panel"
    ["main_options"]="System Info|Disk Usage|Process Monitor|Network|Exit"
    ["main_actions"]="system_info|disk_usage|process_monitor|network_tools|exit"
)

display_menu() {
    local title="$1"
    local options="$2"
    
    clear
    echo "=== $title ==="
    echo
    
    IFS='|' read -ra option_array <<< "$options"
    for i in "${!option_array[@]}"; do
        echo "$((i+1)). ${option_array[$i]}"
    done
    echo
    echo -n "Enter your choice: "
}

execute_action() {
    local action="$1"
    
    case "$action" in
        system_info)
            echo "System Information:"
            echo "Hostname: $(hostname)"
            echo "OS: $(uname -s)"
            echo "Kernel: $(uname -r)"
            echo "Uptime: $(uptime -p)"
            ;;
        disk_usage)
            echo "Disk Usage Summary:"
            df -h | grep -v tmpfs | grep -v udev
            ;;
        process_monitor)
            echo "Top 10 Processes:"
            ps aux --sort=-%cpu | head -11
            ;;
        network_tools)
            echo "Network Interface Status:"
            ip addr show | grep -E "^[0-9]+:|inet "
            ;;
        exit)
            echo "Thank you for using the system administration panel!"
            exit 0
            ;;
        *)
            echo "Unknown action: $action"
            return 1
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
}

main() {
    while true; do
        display_menu "${menu_config[main_title]}" "${menu_config[main_options]}"
        read -r choice
        
        # Validate input
        if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
            echo "Please enter a valid number"
            read -p "Press Enter to continue..."
            continue
        fi
        
        # Get action array
        IFS='|' read -ra action_array <<< "${menu_config[main_actions]}"
        
        # Check if choice is valid
        if [[ $choice -lt 1 || $choice -gt ${#action_array[@]} ]]; then
            echo "Invalid choice. Please try again."
            read -p "Press Enter to continue..."
            continue
        fi
        
        # Execute the selected action
        execute_action "${action_array[$((choice-1))]}"
    done
}

main
```

**Key points** for effective case statement usage:

- Use case statements for multiple discrete conditions rather than if-elif chains
- Pattern matching is case-sensitive unless using specific techniques
- Always include a default case (*) for unexpected inputs
- Consider using functions for complex logic within case branches
- Menu systems benefit from clear separation between display and logic functions

**Example** of a robust file type detector:

```bash
detect_file_type() {
    local file="$1"
    
    [[ ! -f "$file" ]] && { echo "File not found"; return 1; }
    
    case "$file" in
        *.@(jpg|jpeg|png|gif|bmp|tiff))
            echo "Image file"
            identify "$file" 2>/dev/null || echo "Corrupted image file"
            ;;
        *.@(mp4|avi|mkv|mov|wmv|flv))
            echo "Video file"
            ffprobe "$file" 2>&1 | grep -i duration || echo "Cannot read video info"
            ;;
        *.@(txt|log|conf|cfg))
            echo "Text file"
            echo "Lines: $(wc -l < "$file")"
            ;;
        *.@(tar|tar.gz|tgz|zip|rar))
            echo "Archive file"
            case "$file" in
                *.tar|*.tar.gz|*.tgz) tar -tf "$file" | wc -l ;;
                *.zip) unzip -l "$file" | tail -1 ;;
                *) echo "Archive contents unknown" ;;
            esac
            ;;
        *)
            echo "Unknown file type"
            file "$file"
            ;;
    esac
}
```

---

