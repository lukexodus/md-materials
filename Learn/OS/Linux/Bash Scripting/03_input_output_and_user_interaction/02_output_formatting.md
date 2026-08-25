## Output Formatting


### echo vs printf

The `echo` command is simpler and more commonly used for basic output, while `printf` offers more precise control over formatting. The `echo` command behavior can vary between systems, particularly regarding escape sequences and trailing newlines.

**Key points:**

- `echo` automatically adds a newline unless `-n` flag is used
- `printf` requires explicit newline characters (`\n`)
- `printf` follows C-style formatting conventions
- `echo` interpretation of escape sequences depends on shell and system

**Example:**

```bash
# Basic echo usage
echo "Hello World"
echo -n "No newline"
echo -e "Line 1\nLine 2"  # Enable escape sequences

# Printf usage
printf "Hello %s\n" "World"
printf "Number: %d, String: %s\n" 42 "test"
printf "%.2f\n" 3.14159  # Two decimal places
```

### Formatting Numbers and Strings

String and number formatting in bash involves various techniques for alignment, padding, and precision control. The `printf` command provides the most flexibility for formatting operations.

**Key points:**

- Use `%s` for strings, `%d` for integers, `%f` for floating-point numbers
- Width specifiers control minimum field width
- Precision specifiers control decimal places for numbers
- Left and right alignment with `-` flag

**Example:**

```bash
# String formatting
printf "%-10s | %10s\n" "Left" "Right"
printf "%.*s\n" 5 "truncated"  # Limit string length

# Number formatting
printf "%05d\n" 42          # Zero-padded: 00042
printf "%10.2f\n" 3.14159   # Right-aligned with 2 decimals
printf "%-10.2f\n" 3.14159  # Left-aligned with 2 decimals

# Hexadecimal and octal
printf "%x %o\n" 255 255    # ff 377
```

### ANSI Color Codes and Formatting

ANSI escape sequences enable colored output and text formatting in terminals. These codes work by sending special character sequences that terminals interpret as formatting instructions.

**Key points:**

- ANSI codes start with `\033[` or `\e[`
- Color codes: 30-37 for foreground, 40-47 for background
- Text formatting: bold (1), underline (4), reverse (7)
- Reset code (0) returns to normal formatting
- 256-color and RGB support available in modern terminals

**Example:**

```bash
# Basic colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}This is red${NC}"
echo -e "${GREEN}This is green${NC}"
echo -e "${YELLOW}This is bold yellow${NC}"

# Text formatting
BOLD='\033[1m'
UNDERLINE='\033[4m'
REVERSE='\033[7m'

echo -e "${BOLD}Bold text${NC}"
echo -e "${UNDERLINE}Underlined text${NC}"
echo -e "${REVERSE}Reversed text${NC}"

# Background colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'

echo -e "${BG_RED}Red background${NC}"
echo -e "${BG_GREEN}Green background${NC}"

# 256-color support
echo -e "\033[38;5;196mBright red\033[0m"
echo -e "\033[38;5;21mBright blue\033[0m"

# RGB colors (24-bit)
echo -e "\033[38;2;255;100;50mCustom RGB color\033[0m"
```

### Creating Interactive Menus

Interactive menus enhance user experience by providing clear options and input validation. Bash supports various methods for creating menus, from simple select statements to complex custom implementations.

**Key points:**

- `select` statement creates automatic numbered menus
- `read` command captures user input with prompts
- Input validation prevents invalid selections
- Loop structures handle menu repetition
- Case statements process menu choices

**Example:**

```bash
# Simple select menu
echo "Choose an option:"
select option in "Option 1" "Option 2" "Option 3" "Quit"
do
    case $option in
        "Option 1")
            echo "You chose Option 1"
            ;;
        "Option 2")
            echo "You chose Option 2"
            ;;
        "Option 3")
            echo "You chose Option 3"
            ;;
        "Quit")
            break
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done

# Custom menu with colors and validation
show_menu() {
    echo -e "\n${BOLD}Main Menu${NC}"
    echo -e "${GREEN}1.${NC} View files"
    echo -e "${GREEN}2.${NC} Create backup"
    echo -e "${GREEN}3.${NC} System info"
    echo -e "${RED}4.${NC} Exit"
    echo -n "Enter your choice [1-4]: "
}

while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            echo -e "${YELLOW}Listing files...${NC}"
            ls -la
            ;;
        2)
            echo -e "${YELLOW}Creating backup...${NC}"
            # Backup logic here
            ;;
        3)
            echo -e "${YELLOW}System information:${NC}"
            uname -a
            ;;
        4)
            echo -e "${GREEN}Goodbye!${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    
    echo -n "Press Enter to continue..."
    read -r
done

# Advanced menu with function calls
menu_functions() {
    local options=("Display Date" "Show Users" "Disk Usage" "Exit")
    local functions=("show_date" "show_users" "show_disk" "exit")
    
    while true; do
        echo -e "\n${BOLD}System Tools${NC}"
        for i in "${!options[@]}"; do
            printf "%s%d.%s %s\n" "$GREEN" $((i+1)) "$NC" "${options[$i]}"
        done
        
        echo -n "Select option: "
        read -r choice
        
        if [[ $choice -ge 1 && $choice -le ${#options[@]} ]]; then
            ${functions[$((choice-1))]}
        else
            echo -e "${RED}Invalid selection${NC}"
        fi
    done
}

show_date() {
    echo -e "${YELLOW}Current date:${NC} $(date)"
}

show_users() {
    echo -e "${YELLOW}Logged in users:${NC}"
    who
}

show_disk() {
    echo -e "${YELLOW}Disk usage:${NC}"
    df -h
}
```

**Advanced menu techniques:**

```bash
# Menu with timeout
read -t 10 -p "Choose option (timeout 10s): " choice
if [[ $? -gt 0 ]]; then
    echo "Timeout reached, using default option"
fi

# Menu with single character input
echo "Press any key to continue (q to quit):"
read -n 1 -s key
if [[ $key == "q" ]]; then
    exit 0
fi

# Multi-select menu
declare -a selected_items=()
items=("Item 1" "Item 2" "Item 3" "Item 4")

for i in "${!items[@]}"; do
    echo -n "Select ${items[$i]}? (y/n): "
    read -r response
    if [[ $response =~ ^[Yy]$ ]]; then
        selected_items+=("${items[$i]}")
    fi
done

echo "Selected items: ${selected_items[*]}"
```

**Complete Menu System Example**

```bash
#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Menu functions
show_main_menu() {
    clear
    echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║           SYSTEM TOOLS MENU           ║${NC}"
    echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}1.${NC} ${WHITE}File Operations${NC}"
    echo -e "${GREEN}2.${NC} ${WHITE}System Information${NC}"
    echo -e "${GREEN}3.${NC} ${WHITE}Network Tools${NC}"
    echo -e "${GREEN}4.${NC} ${WHITE}Process Management${NC}"
    echo -e "${GREEN}5.${NC} ${WHITE}Color Demo${NC}"
    echo -e "${RED}6.${NC} ${WHITE}Exit${NC}"
    echo
    echo -n "Enter your choice [1-6]: "
}

file_operations_menu() {
    while true; do
        clear
        echo -e "${BOLD}${CYAN}File Operations${NC}"
        echo -e "${YELLOW}1.${NC} List files (detailed)"
        echo -e "${YELLOW}2.${NC} Find files by name"
        echo -e "${YELLOW}3.${NC} Show disk usage"
        echo -e "${YELLOW}4.${NC} Back to main menu"
        echo
        echo -n "Enter your choice [1-4]: "
        
        read -r choice
        case $choice in
            1)
                echo -e "\n${YELLOW}Detailed file listing:${NC}"
                ls -la
                ;;
            2)
                echo -n "Enter filename pattern to search: "
                read -r pattern
                echo -e "\n${YELLOW}Finding files matching '$pattern':${NC}"
                find . -name "*$pattern*" -type f 2>/dev/null
                ;;
            3)
                echo -e "\n${YELLOW}Disk usage:${NC}"
                df -h
                ;;
            4)
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo -e "\n${CYAN}Press Enter to continue...${NC}"
        read -r
    done
}

system_info_menu() {
    clear
    echo -e "${BOLD}${PURPLE}System Information${NC}"
    echo
    echo -e "${YELLOW}System:${NC} $(uname -s)"
    echo -e "${YELLOW}Hostname:${NC} $(hostname)"
    echo -e "${YELLOW}Kernel:${NC} $(uname -r)"
    echo -e "${YELLOW}Architecture:${NC} $(uname -m)"
    echo -e "${YELLOW}Uptime:${NC} $(uptime -p 2>/dev/null || uptime)"
    echo -e "${YELLOW}Current User:${NC} $(whoami)"
    echo -e "${YELLOW}Home Directory:${NC} $HOME"
    echo -e "${YELLOW}Shell:${NC} $SHELL"
    echo -e "${YELLOW}Date:${NC} $(date)"
    
    if command -v free >/dev/null 2>&1; then
        echo -e "\n${YELLOW}Memory Usage:${NC}"
        free -h
    fi
    
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}

network_tools_menu() {
    while true; do
        clear
        echo -e "${BOLD}${GREEN}Network Tools${NC}"
        echo -e "${YELLOW}1.${NC} Show IP addresses"
        echo -e "${YELLOW}2.${NC} Ping test"
        echo -e "${YELLOW}3.${NC} Port scan (if nmap available)"
        echo -e "${YELLOW}4.${NC} Back to main menu"
        echo
        echo -n "Enter your choice [1-4]: "
        
        read -r choice
        case $choice in
            1)
                echo -e "\n${YELLOW}Network interfaces:${NC}"
                if command -v ip >/dev/null 2>&1; then
                    ip addr show | grep -E "(inet|inet6)" | head -10
                elif command -v ifconfig >/dev/null 2>&1; then
                    ifconfig | grep -E "(inet|inet6)" | head -10
                else
                    echo "No suitable network command found"
                fi
                ;;
            2)
                echo -n "Enter hostname or IP to ping: "
                read -r host
                if [[ -n $host ]]; then
                    echo -e "\n${YELLOW}Pinging $host:${NC}"
                    ping -c 4 "$host" 2>/dev/null || echo "Ping failed"
                fi
                ;;
            3)
                if command -v nmap >/dev/null 2>&1; then
                    echo -n "Enter IP/hostname to scan: "
                    read -r target
                    if [[ -n $target ]]; then
                        echo -e "\n${YELLOW}Scanning $target:${NC}"
                        nmap -F "$target" 2>/dev/null || echo "Scan failed"
                    fi
                else
                    echo -e "${RED}nmap not available${NC}"
                fi
                ;;
            4)
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo -e "\n${CYAN}Press Enter to continue...${NC}"
        read -r
    done
}

process_management_menu() {
    clear
    echo -e "${BOLD}${RED}Process Management${NC}"
    echo
    echo -e "${YELLOW}Top 10 processes by CPU usage:${NC}"
    if command -v ps >/dev/null 2>&1; then
        ps aux --sort=-%cpu | head -11
    else
        echo "ps command not available"
    fi
    
    echo -e "\n${YELLOW}Top 10 processes by memory usage:${NC}"
    if command -v ps >/dev/null 2>&1; then
        ps aux --sort=-%mem | head -11
    else
        echo "ps command not available"
    fi
    
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}

color_demo() {
    clear
    echo -e "${BOLD}${WHITE}Color and Formatting Demo${NC}"
    echo
    
    echo -e "${BOLD}Text Colors:${NC}"
    echo -e "${RED}Red text${NC} | ${GREEN}Green text${NC} | ${YELLOW}Yellow text${NC}"
    echo -e "${BLUE}Blue text${NC} | ${PURPLE}Purple text${NC} | ${CYAN}Cyan text${NC}"
    echo
    
    echo -e "${BOLD}Background Colors:${NC}"
    echo -e "\033[41m Red background \033[0m | \033[42m Green background \033[0m | \033[43m Yellow background \033[0m"
    echo
    
    echo -e "${BOLD}Text Formatting:${NC}"
    echo -e "${BOLD}Bold text${NC} | \033[4mUnderlined text\033[0m | \033[7mReversed text\033[0m"
    echo
    
    echo -e "${BOLD}Progress Bar Example:${NC}"
    for i in {1..20}; do
        printf "\r${GREEN}["
        for ((j=1; j<=i; j++)); do
            printf "="
        done
        for ((j=i; j<20; j++)); do
            printf " "
        done
        printf "] %d%%${NC}" $((i*5))
        sleep 0.1
    done
    echo
    
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Input validation function
validate_input() {
    local input=$1
    local min=$2
    local max=$3
    
    if [[ $input =~ ^[0-9]+$ ]] && [[ $input -ge $min && $input -le $max ]]; then
        return 0
    else
        return 1
    fi
}

# Main program loop
main() {
    while true; do
        show_main_menu
        read -r choice
        
        if validate_input "$choice" 1 6; then
            case $choice in
                1)
                    file_operations_menu
                    ;;
                2)
                    system_info_menu
                    ;;
                3)
                    network_tools_menu
                    ;;
                4)
                    process_management_menu
                    ;;
                5)
                    color_demo
                    ;;
                6)
                    echo -e "\n${GREEN}Thank you for using System Tools Menu!${NC}"
                    exit 0
                    ;;
            esac
        else
            echo -e "\n${RED}Invalid option. Please enter a number between 1 and 6.${NC}"
            echo -e "${CYAN}Press Enter to continue...${NC}"
            read -r
        fi
    done
}

# Trap to handle script interruption
trap 'echo -e "\n${YELLOW}Script interrupted. Goodbye!${NC}"; exit 0' INT TERM

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
```

Important related topics include error handling and logging, input validation techniques, terminal detection and compatibility, and advanced formatting with tools like `column` and `tput`.

---

