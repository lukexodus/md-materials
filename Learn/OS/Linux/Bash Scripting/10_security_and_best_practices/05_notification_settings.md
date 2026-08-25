## Notification Settings

SMTP_SERVER="smtp.example.com"
SMTP_PORT=587
NOTIFICATION_EMAIL="admin@example.com"
```

### Examples

#### Example 1: Basic Backup

```bash
./backup.sh backup /home/user /backups/home
```

#### Example 2: Encrypted Backup with Notifications

```bash
./backup.sh --verbose --encrypt --notify admin@example.com backup /var/www /backups/web
```

#### Example 3: Restore from Backup

```bash
./backup.sh restore /backups/web/backup_20250115.tar.xz /var/www
```

### API Reference

#### Core Functions

##### `create_backup(source, destination, options)`

Creates a backup of the specified source directory.

**Parameters:**

- `source` (string): Source directory path
- `destination` (string): Destination backup path
- `options` (array): Backup options

**Returns:**

- `0`: Success
- `1`: Invalid parameters
- `2`: Backup failed

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### License

This project is licensed under the MIT License - see the LICENSE file for details.

```

### Version Control Best Practices

#### Git Repository Structure

Organize your bash projects with a clear and consistent repository structure.

```

project-root/ ├── .gitignore ├── .gitattributes ├── README.md ├── LICENSE ├── CHANGELOG.md ├── VERSION ├── config/ │ ├── config.conf.example │ ├── development.conf │ └── production.conf ├── scripts/ │ ├── backup.sh │ ├── restore.sh │ └── maintenance.sh ├── lib/ │ ├── common.sh │ ├── logging.sh │ └── validation.sh ├── tests/ │ ├── test_backup.sh │ ├── test_restore.sh │ └── test_common.sh ├── docs/ │ ├── installation.md │ ├── configuration.md │ └── api-reference.md └── tools/ ├── install.sh ├── uninstall.sh └── check_dependencies.sh

````

#### .gitignore Configuration

Create comprehensive .gitignore files for bash projects.

```gitignore
## Backup files
*.bak
*.backup
*.tmp
*~

## Log files
*.log
logs/
*.log.*

## Configuration files with sensitive data
config.conf
*.conf
!*.conf.example

## Runtime files
*.pid
*.lock
*.sock

## Cache directories
cache/
tmp/
.cache/

## Database files
*.db
*.sqlite
*.sqlite3

## SSL certificates and keys
*.key
*.crt
*.pem
*.p12

## Environment-specific files
.env
.env.local
.env.production

## IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

## OS-specific files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

## Archive files
*.tar.gz
*.tar.bz2
*.tar.xz
*.zip
*.rar
````

#### Commit Message Standards

Follow conventional commit message format for clear history tracking.

```bash
## Format: <type>(<scope>): <subject>
#
## Types:
## - feat: New feature
## - fix: Bug fix
## - docs: Documentation changes
## - style: Code style changes
## - refactor: Code refactoring
## - test: Adding or modifying tests
## - chore: Maintenance tasks

## Examples:
git commit -m "feat(backup): add encryption support for backup files"
git commit -m "fix(restore): handle missing backup files gracefully"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(logging): improve log message formatting"
git commit -m "test(backup): add unit tests for backup validation"
git commit -m "chore(deps): update required package versions"

## Multi-line commit messages for complex changes:
git commit -m "feat(monitoring): implement comprehensive system monitoring

- Add CPU, memory, and disk usage monitoring
- Implement alert thresholds and notification system
- Add performance metrics collection
- Include automated report generation

Resolves: #123
Closes: #456"
```

#### Branching Strategy

Implement a clear branching strategy for collaborative development.

```bash
## Main branches
main/master    ## Production-ready code
develop        ## Integration branch for features

## Supporting branches
feature/       ## New features
bugfix/        ## Bug fixes
hotfix/        ## Critical production fixes
release/       ## Release preparation

## Branch naming conventions
feature/user-authentication
feature/backup-encryption
bugfix/logging-permission-issue
hotfix/critical-security-patch
release/v2.1.0

## Example workflow
git checkout develop
git checkout -b feature/database-backup
## Make changes and commits
git checkout develop
git merge feature/database-backup
git branch -d feature/database-backup
```

#### Release Management

Implement systematic release management with proper versioning.

```bash
#!/bin/bash
## release.sh - Release management script

## Semantic versioning: MAJOR.MINOR.PATCH
create_release() {
    local version_type="$1"  ## major, minor, patch
    local current_version
    
    ## Get current version
    if [[ -f VERSION ]]; then
        current_version=$(cat VERSION)
    else
        current_version="0.0.0"
    fi
    
    ## Calculate new version
    local new_version
    new_version=$(calculate_next_version "$current_version" "$version_type")
    
    ## Update version files
    echo "$new_version" > VERSION
    update_changelog "$new_version"
    
    ## Create git tag
    git add VERSION CHANGELOG.md
    git commit -m "chore(release): bump version to $new_version"
    git tag -a "v$new_version" -m "Release version $new_version"
    
    echo "Release $new_version created successfully"
}

## CHANGELOG.md format
### [2.1.0] - 2025-01-15

#### Added
- New backup encryption feature
- Support for multiple compression algorithms
- Automated backup rotation

#### Changed
- Improved error handling in restore function
- Updated configuration file format
- Enhanced logging output

#### Fixed
- Fixed permission issues with backup files
- Resolved memory leak in monitoring script
- Corrected timezone handling in reports

#### Removed
- Deprecated legacy backup format support
```

### Maintenance and Updates

#### Code Review Process

Establish comprehensive code review procedures for maintaining quality.

```bash
#!/bin/bash
## code_review_checklist.sh - Automated code review checks

check_shell_standards() {
    echo "Checking shell script standards..."
    
    ## Check shebang
    if ! head -1 "$1" | grep -q "#!/bin/bash"; then
        echo "ERROR: Missing or incorrect shebang"
        return 1
    fi
    
    ## Check for set -e (exit on error)
    if ! grep -q "set -e\|set -euo pipefail" "$1"; then
        echo "WARNING: Consider using 'set -e' for error handling"
    fi
    
    ## Check for proper quoting
    if grep -q '\$[A-Za-z_][A-Za-z0-9_]*[^"]' "$1"; then
        echo "WARNING: Unquoted variables found"
    fi
    
    ## Check function documentation
    local functions
    functions=$(grep -n "^[a-zA-Z_][a-zA-Z0-9_]*(" "$1" | cut -d: -f1)
    
    for line_num in $functions; do
        if ! sed -n "$((line_num-5)),$((line_num-1))p" "$1" | grep -q "^#"; then
            echo "WARNING: Function at line $line_num lacks documentation"
        fi
    done
    
    echo "Shell standards check completed"
}

## ShellCheck integration
run_shellcheck() {
    local script_file="$1"
    
    if command -v shellcheck >/dev/null 2>&1; then
        echo "Running ShellCheck analysis..."
        shellcheck "$script_file"
    else
        echo "ShellCheck not available - install for static analysis"
    fi
}

## Security audit
security_audit() {
    local script_file="$1"
    
    echo "Performing security audit..."
    
    ## Check for potential security issues
    if grep -q "eval\|exec\|system\|`" "$script_file"; then
        echo "WARNING: Potentially dangerous commands found"
    fi
    
    ## Check for hardcoded passwords
    if grep -i "password\|passwd\|pwd" "$script_file" | grep -q "="; then
        echo "WARNING: Potential hardcoded credentials"
    fi
    
    ## Check for insecure file permissions
    if grep -q "chmod.*777\|chmod.*666" "$script_file"; then
        echo "WARNING: Insecure file permissions"
    fi
}
```

#### Automated Testing Framework

Implement comprehensive testing for bash scripts.

```bash
#!/bin/bash
## test_framework.sh - Bash testing framework

## Test runner configuration
readonly TEST_DIR="$(dirname "$0")"
readonly TEST_OUTPUT_DIR="$TEST_DIR/test_results"
readonly TEST_LOG="$TEST_OUTPUT_DIR/test_results.log"

## Test counters
declare -g test_count=0
declare -g test_passed=0
declare -g test_failed=0

## Test assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    ((test_count++))
    
    if [[ "$expected" == "$actual" ]]; then
        ((test_passed++))
        log_test_result "PASS" "$message"
        return 0
    else
        ((test_failed++))
        log_test_result "FAIL" "$message: expected '$expected', got '$actual'"
        return 1
    fi
}

assert_not_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    ((test_count++))
    
    if [[ "$expected" != "$actual" ]]; then
        ((test_passed++))
        log_test_result "PASS" "$message"
        return 0
    else
        ((test_failed++))
        log_test_result "FAIL" "$message: expected not '$expected', got '$actual'"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    ((test_count++))
    
    if eval "$condition"; then
        ((test_passed++))
        log_test_result "PASS" "$message"
        return 0
    else
        ((test_failed++))
        log_test_result "FAIL" "$message: condition '$condition' is false"
        return 1
    fi
}

assert_file_exists() {
    local file_path="$1"
    local message="${2:-File should exist}"
    
    assert_true "[[ -f '$file_path' ]]" "$message: $file_path"
}

assert_command_success() {
    local command="$1"
    local message="${2:-Command should succeed}"
    
    ((test_count++))
    
    if eval "$command" >/dev/null 2>&1; then
        ((test_passed++))
        log_test_result "PASS" "$message"
        return 0
    else
        ((test_failed++))
        log_test_result "FAIL" "$message: command '$command' failed"
        return 1
    fi
}

## Test suite example
test_backup_functionality() {
    echo "Testing backup functionality..."
    
    ## Setup test environment
    local test_source="/tmp/test_source_$"
    local test_backup="/tmp/test_backup_$.tar.gz"
    
    ## Create test data
    mkdir -p "$test_source"
    echo "test data" > "$test_source/test_file.txt"
    echo "more test data" > "$test_source/another_file.txt"
    
    ## Test backup creation
    assert_command_success "create_backup '$test_source' '$test_backup'" "Backup creation should succeed"
    assert_file_exists "$test_backup" "Backup file should exist"
    
    ## Test backup integrity
    local backup_size
    backup_size=$(stat -c%s "$test_backup" 2>/dev/null || echo "0")
    assert_true "[[ $backup_size -gt 0 ]]" "Backup file should not be empty"
    
    ## Test restore functionality
    local test_restore="/tmp/test_restore_$"
    mkdir -p "$test_restore"
    assert_command_success "restore_backup '$test_backup' '$test_restore'" "Restore should succeed"
    assert_file_exists "$test_restore/test_file.txt" "Restored file should exist"
    
    ## Verify file contents
    local original_content restored_content
    original_content=$(cat "$test_source/test_file.txt")
    restored_content=$(cat "$test_restore/test_file.txt")
    assert_equals "$original_content" "$restored_content" "Restored content should match original"
    
    ## Cleanup
    rm -rf "$test_source" "$test_backup" "$test_restore"
}

## Performance testing
test_performance_benchmarks() {
    echo "Running performance benchmarks..."
    
    local large_file="/tmp/large_test_file_$"
    local backup_file="/tmp/performance_backup_$.tar.gz"
    
    ## Create large test file (10MB)
    dd if=/dev/zero of="$large_file" bs=1M count=10 2>/dev/null
    
    ## Measure backup time
    local start_time end_time duration
    start_time=$(date +%s.%N)
    
    create_backup "$(dirname "$large_file")" "$backup_file"
    
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    
    ## Performance assertions
    assert_true "[[ $(echo '$duration < 30' | bc) -eq 1 ]]" "Backup should complete within 30 seconds"
    
    ## Cleanup
    rm -f "$large_file" "$backup_file"
}

## Integration testing
test_integration_scenarios() {
    echo "Running integration tests..."
    
    ## Test configuration file parsing
    local test_config="/tmp/test_config_$.conf"
    cat > "$test_config" << 'EOF'
## Test configuration
BACKUP_DIR="/tmp/test_backups"
RETENTION_DAYS=7
COMPRESSION_TYPE="gzip"
ENABLE_ENCRYPTION=false
EOF
    
    ## Test configuration parsing
    assert_command_success "parse_configuration_file '$test_config'" "Configuration parsing should succeed"
    
    ## Verify configuration variables
    source "$test_config"
    assert_equals "/tmp/test_backups" "$BACKUP_DIR" "BACKUP_DIR should be set correctly"
    assert_equals "7" "$RETENTION_DAYS" "RETENTION_DAYS should be set correctly"
    
    ## Cleanup
    rm -f "$test_config"
}

## Test runner
run_all_tests() {
    echo "Starting test suite..."
    mkdir -p "$TEST_OUTPUT_DIR"
    
    ## Initialize test log
    {
        echo "Test Suite Results - $(date)"
        echo "================================"
    } > "$TEST_LOG"
    
    ## Run test suites
    test_backup_functionality
    test_performance_benchmarks
    test_integration_scenarios
    
    ## Generate test report
    generate_test_report
    
    ## Return exit code based on results
    if [[ $test_failed -gt 0 ]]; then
        return 1
    else
        return 0
    fi
}

## Test report generation
generate_test_report() {
    echo "Generating test report..."
    
    local pass_rate
    pass_rate=$(echo "scale=2; $test_passed * 100 / $test_count" | bc)
    
    {
        echo ""
        echo "Test Summary:"
        echo "============="
        echo "Total tests: $test_count"
        echo "Passed: $test_passed"
        echo "Failed: $test_failed"
        echo "Pass rate: ${pass_rate}%"
        echo ""
    } >> "$TEST_LOG"
    
    ## Display summary
    cat "$TEST_LOG"
    
    ## Generate HTML report if requested
    if [[ "${GENERATE_HTML_REPORT:-false}" == "true" ]]; then
        generate_html_report
    fi
}

log_test_result() {
    local status="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $status: $message" >> "$TEST_LOG"
    
    if [[ "$status" == "PASS" ]]; then
        echo "✓ $message"
    else
        echo "✗ $message"
    fi
}
```

#### Continuous Integration Pipeline

Implement automated testing and deployment pipelines.

```bash
#!/bin/bash
## ci_pipeline.sh - Continuous Integration pipeline

## Pipeline configuration
readonly CI_CONFIG_FILE="${CI_CONFIG_FILE:-ci_config.yml}"
readonly ARTIFACTS_DIR="${ARTIFACTS_DIR:-artifacts}"
readonly REPORTS_DIR="${REPORTS_DIR:-reports}"

## Pipeline stages
pipeline_stages=(
    "code_quality_check"
    "static_analysis"
    "unit_tests"
    "integration_tests"
    "security_scan"
    "performance_tests"
    "build_artifacts"
    "deployment_preparation"
)

## Code quality checks
code_quality_check() {
    echo "Running code quality checks..."
    
    ## Check file permissions
    find . -name "*.sh" -type f ! -perm -u+x -exec echo "WARNING: Script not executable: {}" \;
    
    ## Check for trailing whitespace
    if grep -r "[[:space:]]$" --include="*.sh" .; then
        echo "ERROR: Trailing whitespace found"
        return 1
    fi
    
    ## Check for consistent indentation
    if grep -r \t' --include="*.sh" .; then
        echo "ERROR: Tab characters found - use spaces for indentation"
        return 1
    fi
    
    ## Check for required documentation
    for script in *.sh; do
        if ! head -20 "$script" | grep -q "Description:"; then
            echo "WARNING: Missing description in $script"
        fi
    done
    
    echo "Code quality check completed"
    return 0
}

## Static analysis with multiple tools
static_analysis() {
    echo "Running static analysis..."
    
    ## ShellCheck analysis
    if command -v shellcheck >/dev/null 2>&1; then
        echo "Running ShellCheck..."
        local shellcheck_report="$REPORTS_DIR/shellcheck_report.txt"
        
        find . -name "*.sh" -type f -exec shellcheck {} + > "$shellcheck_report" 2>&1
        
        if [[ -s "$shellcheck_report" ]]; then
            echo "ShellCheck issues found:"
            cat "$shellcheck_report"
            return 1
        fi
    else
        echo "ShellCheck not available - skipping"
    fi
    
    ## Bash syntax check
    echo "Checking bash syntax..."
    for script in *.sh; do
        if ! bash -n "$script"; then
            echo "ERROR: Syntax error in $script"
            return 1
        fi
    done
    
    echo "Static analysis completed"
    return 0
}

## Comprehensive test execution
run_comprehensive_tests() {
    echo "Running comprehensive test suite..."
    
    ## Unit tests
    if [[ -d "tests/unit" ]]; then
        echo "Running unit tests..."
        for test_file in tests/unit/test_*.sh; do
            if [[ -f "$test_file" ]]; then
                if ! bash "$test_file"; then
                    echo "ERROR: Unit test failed: $test_file"
                    return 1
                fi
            fi
        done
    fi
    
    ## Integration tests
    if [[ -d "tests/integration" ]]; then
        echo "Running integration tests..."
        for test_file in tests/integration/test_*.sh; do
            if [[ -f "$test_file" ]]; then
                if ! bash "$test_file"; then
                    echo "ERROR: Integration test failed: $test_file"
                    return 1
                fi
            fi
        done
    fi
    
    ## Generate test coverage report
    generate_coverage_report
    
    echo "Comprehensive tests completed"
    return 0
}

## Security scanning
security_scan() {
    echo "Running security scan..."
    
    ## Check for hardcoded secrets
    if grep -r -i "password\|secret\|token\|key" --include="*.sh" . | grep -v "^#"; then
        echo "WARNING: Potential hardcoded secrets found"
    fi
    
    ## Check for dangerous commands
    local dangerous_patterns=(
        "rm -rf \*"
        "chmod 777"
        "eval.*\$"
        "exec.*\$"
        "system.*\$"
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -r "$pattern" --include="*.sh" .; then
            echo "WARNING: Potentially dangerous pattern found: $pattern"
        fi
    done
    
    ## Check file permissions
    find . -name "*.sh" -type f -perm -o+w -exec echo "WARNING: World-writable script: {}" \;
    
    echo "Security scan completed"
    return 0
}

## Performance testing
performance_tests() {
    echo "Running performance tests..."
    
    ## Test script execution time
    for script in *.sh; do
        if [[ -x "$script" ]]; then
            local start_time end_time execution_time
            start_time=$(date +%s.%N)
            
            timeout 30s "./$script" --help >/dev/null 2>&1 || true
            
            end_time=$(date +%s.%N)
            execution_time=$(echo "$end_time - $start_time" | bc)
            
            echo "Execution time for $script: ${execution_time}s"
            
            ## Fail if script takes too long
            if [[ $(echo "$execution_time > 10" | bc) -eq 1 ]]; then
                echo "ERROR: Script $script takes too long to execute"
                return 1
            fi
        fi
    done
    
    echo "Performance tests completed"
    return 0
}

## Build artifacts
build_artifacts() {
    echo "Building deployment artifacts..."
    
    mkdir -p "$ARTIFACTS_DIR"
    
    ## Create release package
    local release_name="bash_scripts_$(date +%Y%m%d_%H%M%S)"
    local release_package="$ARTIFACTS_DIR/${release_name}.tar.gz"
    
    ## Package scripts and configurations
    tar -czf "$release_package" \
        --exclude="tests/" \
        --exclude="$ARTIFACTS_DIR" \
        --exclude="$REPORTS_DIR" \
        --exclude=".git*" \
        --exclude="*.tmp" \
        --exclude="*.log" \
        .
    
    ## Generate checksum
    sha256sum "$release_package" > "${release_package}.sha256"
    
    ## Create installation script
    create_installation_script "$release_name"
    
    echo "Artifacts built successfully"
    return 0
}

## Create installation script
create_installation_script() {
    local release_name="$1"
    local install_script="$ARTIFACTS_DIR/install_${release_name}.sh"
    
    cat > "$install_script" << 'EOF'
#!/bin/bash
## Auto-generated installation script

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/opt/bash_scripts}"
RELEASE_PACKAGE=""

install_package() {
    echo "Installing bash scripts to $INSTALL_DIR..."
    
    ## Create installation directory
    sudo mkdir -p "$INSTALL_DIR"
    
    ## Extract package
    sudo tar -xzf "$RELEASE_PACKAGE" -C "$INSTALL_DIR"
    
    ## Set permissions
    sudo find "$INSTALL_DIR" -name "*.sh" -type f -exec chmod +x {} \;
    
    ## Create symlinks
    sudo ln -sf "$INSTALL_DIR/main.sh" /usr/local/bin/bash-scripts
    
    echo "Installation completed successfully"
}

## Parse command line arguments
while [[ $## -gt 0 ]]; do
    case $1 in
        --package)
            RELEASE_PACKAGE="$2"
            shift 2
            ;;
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 --package PACKAGE_FILE [--install-dir DIR]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$RELEASE_PACKAGE" ]]; then
    echo "Error: Package file is required"
    exit 1
fi

install_package
EOF
    
    chmod +x "$install_script"
}

## Pipeline execution
execute_pipeline() {
    echo "Starting CI/CD pipeline..."
    
    ## Create output directories
    mkdir -p "$ARTIFACTS_DIR" "$REPORTS_DIR"
    
    ## Execute pipeline stages
    for stage in "${pipeline_stages[@]}"; do
        echo "Executing stage: $stage"
        
        if ! "$stage"; then
            echo "ERROR: Pipeline stage failed: $stage"
            return 1
        fi
        
        echo "Stage completed successfully: $stage"
    done
    
    echo "Pipeline executed successfully"
    return 0
}

## Pipeline reporting
generate_pipeline_report() {
    local report_file="$REPORTS_DIR/pipeline_report.html"
    
    cat > "$report_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>CI/CD Pipeline Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; }
        .failure { color: red; }
        .warning { color: orange; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>CI/CD Pipeline Report</h1>
    <p>Generated: $(date)</p>
    
    <h2>Pipeline Summary</h2>
    <table>
        <tr><th>Stage</th><th>Status</th><th>Duration</th></tr>
        <!-- Pipeline results would be inserted here -->
    </table>
    
    <h2>Test Results</h2>
    <p>Total tests: ${test_count:-0}</p>
    <p>Passed: ${test_passed:-0}</p>
    <p>Failed: ${test_failed:-0}</p>
    
    <h2>Artifacts</h2>
    <ul>
        <!-- Artifact list would be inserted here -->
    </ul>
</body>
</html>
EOF
    
    echo "Pipeline report generated: $report_file"
}

## Update and maintenance procedures
update_maintenance() {
    echo "Performing maintenance updates..."
    
    ## Update documentation
    update_documentation
    
    ## Check for dependency updates
    check_dependency_updates
    
    ## Clean up old artifacts
    cleanup_old_artifacts
    
    ## Update version information
    update_version_info
    
    echo "Maintenance updates completed"
}

## Documentation updates
update_documentation() {
    echo "Updating documentation..."
    
    ## Generate API documentation
    generate_api_documentation
    
    ## Update README with latest examples
    update_readme_examples
    
    ## Generate changelog
    generate_changelog
}

## Dependency management
check_dependency_updates() {
    echo "Checking for dependency updates..."
    
    ## Check required system packages
    local required_packages=(
        "bash"
        "curl"
        "jq"
        "bc"
        "tar"
        "gzip"
    )
    
    for package in "${required_packages[@]}"; do
        if ! command -v "$package" >/dev/null 2>&1; then
            echo "WARNING: Required package not found: $package"
        fi
    done
    
    ## Check for newer bash version
    local bash_version
    bash_version=$(bash --version | head -1 | grep -o '[0-9]\+\.[0-9]\+')
    
    if [[ $(echo "$bash_version < 4.0" | bc) -eq 1 ]]; then
        echo "WARNING: Bash version $bash_version is outdated"
    fi
}

## Cleanup procedures
cleanup_old_artifacts() {
    echo "Cleaning up old artifacts..."
    
    ## Remove artifacts older than 30 days
    find "$ARTIFACTS_DIR" -name "*.tar.gz" -type f -mtime +30 -delete
    find "$REPORTS_DIR" -name "*.html" -type f -mtime +30 -delete
    
    ## Remove temporary files
    find . -name "*.tmp" -type f -delete
    find . -name "*.log" -type f -mtime +7 -delete
}

## Main execution
main() {
    case "${1:-pipeline}" in
        "pipeline")
            execute_pipeline
            ;;
        "test")
            run_comprehensive_tests
            ;;
        "security")
            security_scan
            ;;
        "maintenance")
            update_maintenance
            ;;
        "report")
            generate_pipeline_report
            ;;
        *)
            echo "Usage: $0 {pipeline|test|security|maintenance|report}"
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

**Key points** for implementing best practices and standards:

- Establish and enforce consistent code style guidelines across all scripts
- Implement comprehensive documentation standards with inline comments and external documentation
- Use proper version control workflows with meaningful commit messages and branching strategies
- Create automated testing frameworks and continuous integration pipelines
- Implement regular maintenance procedures and dependency management
- Follow security best practices and conduct regular security audits
- Use static analysis tools like ShellCheck for code quality assurance

**Next steps** for advanced best practices include implementing automated code formatting tools, creating custom linting rules for organization-specific standards, developing automated deployment pipelines, and establishing code review templates and procedures.

---

