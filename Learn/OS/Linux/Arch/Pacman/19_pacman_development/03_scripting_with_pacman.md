## Scripting with Pacman


### Overview

Scripting with pacman enables automation of package management tasks, batch operations, and integration with other tools. Understanding pacman's command-line interface and output formats is essential for reliable scripts.

### Query Operations (Safe for Scripting)

#### Listing Packages

**List all installed packages:**
```bash
pacman -Q
```

Output format:
```
package-name version
firefox 120.0-1
linux 6.6.1.arch1-1
```

**List with full paths:**
```bash
pacman -Ql package-name
```

**Count installed packages:**
```bash
pacman -Q | wc -l
```

**Get specific package version:**
```bash
pacman -Q | grep "^firefox"
# Output: firefox 120.0-1
```

#### Querying Package Information

**Get package version:**
```bash
pacman -Q firefox | awk '{print $2}'
# Output: 120.0-1
```

**Check if package is installed:**
```bash
if pacman -Q firefox >/dev/null 2>&1; then
    echo "Firefox is installed"
else
    echo "Firefox is not installed"
fi
```

**List package dependencies:**
```bash
pacman -Qi firefox | grep "Depends On"
```

**List packages installed as dependencies:**
```bash
pacman -Qd
```

**List explicitly installed packages:**
```bash
pacman -Qe
```

**List foreign packages (AUR):**
```bash
pacman -Qm
```

#### Searching

**Search repositories:**
```bash
pacman -Ss firefox
```

**Search installed packages:**
```bash
pacman -Qs firefox
```

**Search by file:**
```bash
pacman -F /usr/bin/firefox
```

**Find package providing command:**
```bash
pacman -F firefox
```

### Scripting Patterns

#### Safe Query Script

```bash
#!/bin/bash
# query-packages.sh - Safe script to query packages

# Function to get package version
get_version() {
    local pkg="$1"
    pacman -Q "$pkg" 2>/dev/null | awk '{print $2}'
}

# Function to check if installed
is_installed() {
    local pkg="$1"
    pacman -Q "$pkg" >/dev/null 2>&1
}

# Function to list package files
list_files() {
    local pkg="$1"
    pacman -Ql "$pkg" 2>/dev/null | awk '{print $2}'
}

# Function to check if package is dependency
is_dependency() {
    local pkg="$1"
    pacman -Q "$pkg" >/dev/null 2>&1 || return 1
    
    local reason=$(pacman -Qi "$pkg" | grep "Install Reason" | awk '{print $3}')
    [ "$reason" == "Dependency" ] && return 0 || return 1
}

# Example usage
PACKAGE="firefox"

if is_installed "$PACKAGE"; then
    VERSION=$(get_version "$PACKAGE")
    echo "$PACKAGE version: $VERSION"
    
    if ! is_dependency "$PACKAGE"; then
        echo "$PACKAGE is explicitly installed"
    fi
fi
```

#### Package Comparison Script

```bash
#!/bin/bash
# compare-versions.sh - Compare package versions

compare_versions() {
    local pkg="$1"
    local local_version=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}')
    local repo_version=$(pacman -Si "$pkg" 2>/dev/null | grep "Version" | awk '{print $3}')
    
    if [ -z "$local_version" ]; then
        echo "$pkg: Not installed"
        return 1
    fi
    
    if [ -z "$repo_version" ]; then
        echo "$pkg: Not in repositories"
        return 1
    fi
    
    echo "$pkg:"
    echo "  Installed: $local_version"
    echo "  Repository: $repo_version"
    
    # Use vercmp if available
    if command -v vercmp &>/dev/null; then
        case $(vercmp "$local_version" "$repo_version") in
            -1) echo "  Status: Update available" ;;
            0)  echo "  Status: Up to date" ;;
            1)  echo "  Status: Newer than repo" ;;
        esac
    fi
}

# Test
compare_versions "firefox"
compare_versions "linux"
```

### Batch Operations

#### Batch Installation Script

```bash
#!/bin/bash
# batch-install.sh - Install multiple packages with safety checks

# Configuration
PACKAGES=(
    "firefox"
    "thunderbird"
    "vlc"
    "gimp"
    "blender"
)

# Dry run mode
DRY_RUN=false
LOG_FILE="/tmp/batch-install-$(date +%Y%m%d-%H%M%S).log"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift ;;
        *) PACKAGES+=("$1"); shift ;;
    esac
done

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Analyze packages
log "Analyzing packages..."

INSTALL_LIST=()
ALREADY_INSTALLED=()
NOT_FOUND=()

for pkg in "${PACKAGES[@]}"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
        ALREADY_INSTALLED+=("$pkg")
    elif pacman -Si "$pkg" >/dev/null 2>&1; then
        INSTALL_LIST+=("$pkg")
    else
        NOT_FOUND+=("$pkg")
    fi
done

# Report analysis
log "Analysis results:"
log "  To install: ${#INSTALL_LIST[@]} packages"
log "  Already installed: ${#ALREADY_INSTALLED[@]} packages"
log "  Not found: ${#NOT_FOUND[@]} packages"

# Show details
if [ ${#INSTALL_LIST[@]} -gt 0 ]; then
    log "Packages to install:"
    printf '%s\n' "${INSTALL_LIST[@]}" | while read pkg; do
        log "  - $pkg"
    done
fi

if [ ${#NOT_FOUND[@]} -gt 0 ]; then
    log "Packages not found:"
    printf '%s\n' "${NOT_FOUND[@]}" | while read pkg; do
        log "  - $pkg"
    done
fi

# Proceed with installation if not dry-run
if [ $DRY_RUN = false ] && [ ${#INSTALL_LIST[@]} -gt 0 ]; then
    log "Proceeding with installation..."
    
    sudo pacman -S "${INSTALL_LIST[@]}" --needed
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        log "Installation completed successfully"
    else
        log "Installation failed with exit code $EXIT_CODE"
    fi
else
    log "Dry run mode - no changes made"
fi

log "Log saved to: $LOG_FILE"
```

#### Batch Removal Script

```bash
#!/bin/bash
# batch-remove.sh - Remove packages with dependency check

# Packages to remove
PACKAGES=("package1" "package2" "package3")

remove_packages() {
    local packages=("$@")
    
    # Check which packages are installed
    local to_remove=()
    for pkg in "${packages[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            to_remove+=("$pkg")
        else
            echo "Package '$pkg' not installed, skipping"
        fi
    done
    
    if [ ${#to_remove[@]} -eq 0 ]; then
        echo "No packages to remove"
        return 0
    fi
    
    # Show what will be removed
    echo "Packages to remove:"
    printf '%s\n' "${to_remove[@]}"
    
    # Check dependencies
    echo ""
    echo "Checking dependencies..."
    pacman -Rs "${to_remove[@]}" --print
    
    read -p "Proceed? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo pacman -Rns "${to_remove[@]}"
    fi
}

remove_packages "${PACKAGES[@]}"
```

### Output Parsing and Processing

#### Parse Package Information

```bash
#!/bin/bash
# parse-packages.sh - Parse and process package information

parse_package_info() {
    local pkg="$1"
    
    pacman -Qi "$pkg" | while IFS=: read -r key value; do
        # Trim whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Process different fields
        case "$key" in
            "Name")
                echo "name=$value"
                ;;
            "Version")
                echo "version=$value"
                ;;
            "Description")
                echo "description=$value"
                ;;
            "Install Date")
                echo "install_date=$value"
                ;;
            "Install Reason")
                echo "install_reason=$value"
                ;;
            "Depends On")
                echo "dependencies=$value"
                ;;
        esac
    done
}

# Usage
parse_package_info "firefox" | while read line; do
    eval "$line"
done

echo "Firefox version: $version"
echo "Reason: $install_reason"
```

#### Generate Package Report

```bash
#!/bin/bash
# generate-report.sh - Generate system package report

generate_report() {
    local report_file="/tmp/package-report-$(date +%Y%m%d).txt"
    
    {
        echo "=== Arch Linux Package Report ==="
        echo "Generated: $(date)"
        echo ""
        
        # Summary
        echo "=== Summary ==="
        echo "Total installed packages: $(pacman -Q | wc -l)"
        echo "Explicitly installed: $(pacman -Qe | wc -l)"
        echo "Installed as dependencies: $(pacman -Qd | wc -l)"
        echo "Foreign packages (AUR): $(pacman -Qm | wc -l)"
        echo ""
        
        # Recently installed
        echo "=== Recently Installed Packages ==="
        grep "installed" /var/log/pacman.log | tail -10 | awk -F' ' '{print $4}' | sort -u
        echo ""
        
        # Recently updated
        echo "=== Recently Updated Packages ==="
        grep "upgraded" /var/log/pacman.log | tail -10 | awk -F' ' '{print $4}' | sort -u
        echo ""
        
        # Largest packages
        echo "=== Top 20 Largest Packages ==="
        expac -H M '%m\t%n' | sort -rh | head -20
        echo ""
        
        # Orphaned dependencies
        echo "=== Orphaned Packages ==="
        pacman -Qtdq
        
    } | tee "$report_file"
    
    echo ""
    echo "Report saved to: $report_file"
}

generate_report
```

### System Maintenance Scripts

#### Automated Cleanup Script

```bash
#!/bin/bash
# auto-cleanup.sh - Automated system cleanup

cleanup_cache() {
    echo "Cleaning package cache..."
    
    # Keep only 2 most recent versions
    paccache -rk2
    
    # Remove uninstalled packages
    paccache -ruk0
    
    CACHE_SIZE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
    echo "Cache size after cleanup: $CACHE_SIZE"
}

cleanup_orphans() {
    echo "Checking for orphaned packages..."
    
    ORPHANS=$(pacman -Qtdq)
    
    if [ -z "$ORPHANS" ]; then
        echo "No orphaned packages found"
        return 0
    fi
    
    echo "Removing orphaned packages..."
    echo "$ORPHANS" | while read pkg; do
        echo "  - $pkg"
    done
    
    sudo pacman -Rns $ORPHANS
}

cleanup_old_logs() {
    echo "Cleaning old logs..."
    
    # Clean journal (keep 2 weeks)
    sudo journalctl --vacuum-time=2weeks
    
    # Clean pacman logs older than 3 months
    find /var/log -name "pacman*.log*" -mtime +90 -delete 2>/dev/null
}

main() {
    echo "=== System Cleanup ==="
    
    cleanup_cache
    echo ""
    
    cleanup_orphans
    echo ""
    
    cleanup_old_logs
    echo ""
    
    echo "Cleanup completed"
}

main
```

#### Update with Notifications

```bash
#!/bin/bash
# update-with-notify.sh - System update with notifications

update_system() {
    local start_time=$(date +%s)
    
    # Notify start
    notify-send "System Update" "Starting system update..."
    
    # Perform update
    pacman -Syu 2>&1 | tee /tmp/pacman-update.log
    local exit_code=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Notify completion
    if [ $exit_code -eq 0 ]; then
        notify-send -u normal "Update Complete" "System updated in $((duration / 60)) minutes"
        
        # Check if reboot needed
        if [ -f /usr/lib/modules/$(uname -r) ]; then
            notify-send "No reboot needed" "Kernel is up to date"
        else
            notify-send -u critical "Reboot Required" "Kernel was updated, reboot recommended"
        fi
    else
        notify-send -u critical "Update Failed" "See /tmp/pacman-update.log for details"
    fi
}

update_system
```

### Error Handling in Scripts

#### Robust Pacman Script

```bash
#!/bin/bash
# robust-script.sh - Robust pacman scripting with error handling

set -euo pipefail

# Error handler
trap 'error "Script failed at line $LINENO"' ERR

error() {
    echo "ERROR: $1" >&2
    exit 1
}

warning() {
    echo "WARNING: $1" >&2
}

info() {
    echo "INFO: $1"
}

# Verify pacman is available
check_dependencies() {
    if ! command -v pacman &>/dev/null; then
        error "pacman not found"
    fi
}

# Run with error handling
safe_pacman_query() {
    local cmd="$1"
    shift
    
    if ! output=$(pacman $cmd "$@" 2>&1); then
        warning "pacman query failed: $cmd $*"
        return 1
    fi
    
    echo "$output"
}

# Main script
main() {
    check_dependencies
    
    info "Querying installed packages..."
    
    if safe_pacman_query -Q firefox; then
        info "Firefox is installed"
    else
        warning "Firefox is not installed"
    fi
    
    info "Script completed successfully"
}

main "$@"
```

### Best Practices for Pacman Scripts

#### Do's and Don'ts

**Do:**
- Use `-Q` queries in scripts (safe, read-only)
- Check exit codes
- Validate inputs
- Log operations
- Handle errors gracefully
- Use `--needed` flag to avoid reinstalls

**Don't:**
- Run `pacman -Syu` without user confirmation
- Parse human-readable output (formats may change)
- Ignore errors
- Use temporary files without cleanup
- Run as root unnecessarily

#### Parse JSON When Available

```bash
#!/bin/bash
# Use expac for structured output

# Get package size in bytes
expac '%s' firefox

# Get multiple fields
expac '%n\t%v\t%s' firefox

# Format as JSON (if available)
expac --json '%n %v %s' firefox 2>/dev/null || echo "JSON not supported"
```

#### Robustness Techniques

```bash
#!/bin/bash
# Defensive programming for pacman scripts

# Don't fail on no matches
pacman -Q nonexistent 2>/dev/null || true

# Iterate safely
while IFS= read -r line; do
    # Process line
    echo "$line"
done < <(pacman -Q)

# Avoid word splitting
packages=($(pacman -Qmq))
for pkg in "${packages[@]}"; do
    echo "$pkg"
done

# Check return codes
if pacman -Q firefox >/dev/null 2>&1; then
    echo "firefox is installed"
else
    echo "firefox is not installed"
fi
```

Pacman scripting enables powerful automation while maintaining system stability through careful query operations and proper error handling.

