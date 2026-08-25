## Data Processing Pipelines


Data processing pipelines in bash scripting provide powerful automation capabilities for extracting, transforming, and loading data across various systems. These pipelines leverage bash's text processing strengths, system integration capabilities, and extensive toolchain to create efficient workflows for handling large volumes of data.

### ETL Scripts for Data Processing

ETL (Extract, Transform, Load) operations form the backbone of data processing pipelines, where bash excels due to its native text manipulation capabilities and seamless integration with command-line tools.

#### Extraction Components

Bash ETL scripts can extract data from multiple sources including databases, APIs, flat files, and system logs. Database extraction typically involves tools like `mysql`, `psql`, or `sqlite3` with connection parameters and query execution. API extraction utilizes `curl` or `wget` with authentication headers, rate limiting, and error handling mechanisms.

```bash
# Database extraction with error handling
extract_database() {
    local query="$1"
    local output_file="$2"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" \
        -e "$query" --batch --raw > "$output_file" 2>/dev/null
    
    if [[ $? -ne 0 ]]; then
        log_error "Database extraction failed for query: $query"
        return 1
    fi
}

# API extraction with retry logic
extract_api() {
    local endpoint="$1"
    local output_file="$2"
    local max_retries=3
    
    for ((i=1; i<=max_retries; i++)); do
        if curl -H "Authorization: Bearer $API_TOKEN" \
               -H "Accept: application/json" \
               "$endpoint" -o "$output_file" --fail; then
            return 0
        fi
        sleep $((i * 2))
    done
    
    log_error "API extraction failed after $max_retries attempts"
    return 1
}
```

#### Transformation Operations

Data transformation in bash leverages tools like `awk`, `sed`, `cut`, `sort`, and `join` for complex data manipulation. These operations include field extraction, data cleaning, format conversion, aggregation, and validation.

```bash
# Complex data transformation pipeline
transform_sales_data() {
    local input_file="$1"
    local output_file="$2"
    
    # Clean and standardize data
    awk -F',' '
    BEGIN { OFS="," }
    NR > 1 {  # Skip header
        # Clean whitespace and convert to uppercase
        gsub(/^[ \t]+|[ \t]+$/, "", $2)  # Trim product name
        $2 = toupper($2)
        
        # Validate and format price
        if ($3 ~ /^[0-9]+(\.[0-9]{1,2})?$/) {
            $3 = sprintf("%.2f", $3)
        } else {
            next  # Skip invalid records
        }
        
        # Format date
        if ($4 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
            print $1, $2, $3, $4
        }
    }' "$input_file" | sort -t',' -k4,4 > "$output_file"
}

# Advanced aggregation with associative arrays
aggregate_by_region() {
    local input_file="$1"
    
    awk -F',' '
    {
        region = $1
        sales = $3
        region_sales[region] += sales
        region_count[region]++
    }
    END {
        print "Region,Total_Sales,Avg_Sales,Count"
        for (region in region_sales) {
            avg = region_sales[region] / region_count[region]
            printf "%s,%.2f,%.2f,%d\n", region, region_sales[region], avg, region_count[region]
        }
    }' "$input_file"
}
```

#### Loading Mechanisms

The loading phase involves inserting transformed data into target systems, with considerations for data integrity, performance, and error recovery. Bash scripts can handle various loading scenarios including database inserts, file generation, and API uploads.

```bash
# Batch loading with transaction support
load_to_database() {
    local data_file="$1"
    local table_name="$2"
    
    # Create staging table
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF
    CREATE TABLE IF NOT EXISTS ${table_name}_staging LIKE $table_name;
    TRUNCATE TABLE ${table_name}_staging;
EOF

    # Load data into staging
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" \
        --local-infile=1 -e "
        LOAD DATA LOCAL INFILE '$data_file' 
        INTO TABLE ${table_name}_staging 
        FIELDS TERMINATED BY ',' 
        LINES TERMINATED BY '\n' 
        IGNORE 1 ROWS;"
    
    # Validate and swap tables
    if validate_staging_data "${table_name}_staging"; then
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF
        START TRANSACTION;
        RENAME TABLE $table_name TO ${table_name}_backup,
                     ${table_name}_staging TO $table_name;
        COMMIT;
EOF
        log_info "Data loaded successfully to $table_name"
    else
        log_error "Data validation failed, rolling back"
        return 1
    fi
}
```

### Report Generation Automation

Automated report generation combines data processing with formatting and distribution capabilities, creating comprehensive reporting solutions that can run on scheduled intervals.

#### Data Collection and Analysis

Report generation begins with collecting data from multiple sources and performing analytical operations to derive meaningful insights. This involves connecting to databases, processing log files, and aggregating metrics.

```bash
# Comprehensive report data collection
collect_report_data() {
    local report_date="$1"
    local temp_dir="/tmp/report_$$"
    mkdir -p "$temp_dir"
    
    # Collect sales data
    extract_database "
        SELECT region, product_category, SUM(sales_amount) as total_sales,
               COUNT(*) as transaction_count
        FROM sales 
        WHERE DATE(transaction_date) = '$report_date'
        GROUP BY region, product_category
    " "$temp_dir/sales_data.csv"
    
    # Collect performance metrics
    extract_api "https://api.company.com/metrics?date=$report_date" \
               "$temp_dir/performance_metrics.json"
    
    # Process web server logs
    zcat /var/log/nginx/access.log.gz | \
    awk -v date="$report_date" '
    $4 ~ date {
        if ($9 ~ /^[45][0-9][0-9]$/) errors++
        else success++
        total++
    }
    END {
        printf "Total Requests: %d\nSuccessful: %d\nErrors: %d\nError Rate: %.2f%%\n",
               total, success, errors, (errors/total)*100
    }' > "$temp_dir/web_metrics.txt"
    
    echo "$temp_dir"
}

# Advanced analytics with statistical calculations
calculate_analytics() {
    local data_file="$1"
    
    awk -F',' '
    NR > 1 {
        values[NR-1] = $3  # Assuming sales amount in column 3
        sum += $3
        count++
    }
    END {
        # Calculate mean
        mean = sum / count
        
        # Calculate median
        for (i = 1; i <= count; i++) {
            for (j = i + 1; j <= count; j++) {
                if (values[i] > values[j]) {
                    temp = values[i]
                    values[i] = values[j]
                    values[j] = temp
                }
            }
        }
        median = (count % 2) ? values[int(count/2) + 1] : (values[count/2] + values[count/2 + 1]) / 2
        
        # Calculate standard deviation
        variance_sum = 0
        for (i = 1; i <= count; i++) {
            variance_sum += (values[i] - mean) ^ 2
        }
        std_dev = sqrt(variance_sum / count)
        
        printf "Analytics Summary:\n"
        printf "Mean: %.2f\n", mean
        printf "Median: %.2f\n", median
        printf "Standard Deviation: %.2f\n", std_dev
        printf "Total Records: %d\n", count
    }' "$data_file"
}
```

#### Report Formatting and Templates

Report formatting involves creating structured documents with headers, tables, charts, and summaries. Bash can generate various formats including HTML, CSV, and plain text reports.

```bash
# HTML report generation with CSS styling
generate_html_report() {
    local data_dir="$1"
    local output_file="$2"
    local report_date="$3"
    
    cat > "$output_file" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Daily Sales Report - $report_date</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .metric { background-color: #e8f4f8; padding: 10px; margin: 10px 0; }
        .error { color: red; }
        .success { color: green; }
    </style>
</head>
<body>
    <h1>Daily Sales Report</h1>
    <h2>Report Date: $report_date</h2>
    
    <div class="metric">
        <h3>Key Metrics</h3>
EOF

    # Add performance metrics
    if [[ -f "$data_dir/web_metrics.txt" ]]; then
        echo "        <h4>Web Performance</h4>" >> "$output_file"
        echo "        <pre>" >> "$output_file"
        cat "$data_dir/web_metrics.txt" >> "$output_file"
        echo "        </pre>" >> "$output_file"
    fi
    
    # Add sales data table
    if [[ -f "$data_dir/sales_data.csv" ]]; then
        echo "    </div>" >> "$output_file"
        echo "    <h3>Sales Data by Region and Category</h3>" >> "$output_file"
        echo "    <table>" >> "$output_file"
        
        # Generate table headers
        head -1 "$data_dir/sales_data.csv" | \
        sed 's/,/<\/th><th>/g; s/^/<tr><th>/; s/$/<\/th><\/tr>/' >> "$output_file"
        
        # Generate table rows
        tail -n +2 "$data_dir/sales_data.csv" | \
        awk -F',' '{
            printf "<tr><td>%s</td><td>%s</td><td>$%.2f</td><td>%s</td></tr>\n",
                   $1, $2, $3, $4
        }' >> "$output_file"
        
        echo "    </table>" >> "$output_file"
    fi
    
    cat >> "$output_file" <<EOF
    <footer>
        <p>Report generated on $(date) by automated pipeline</p>
    </footer>
</body>
</html>
EOF
}

# PDF report generation using wkhtmltopdf
generate_pdf_report() {
    local html_file="$1"
    local pdf_file="$2"
    
    wkhtmltopdf --page-size A4 \
                --margin-top 0.75in \
                --margin-right 0.75in \
                --margin-bottom 0.75in \
                --margin-left 0.75in \
                --encoding UTF-8 \
                "$html_file" "$pdf_file"
}
```

#### Distribution and Notifications

Report distribution involves sending generated reports to stakeholders through various channels including email, file shares, and web portals.

```bash
# Email distribution with attachments
distribute_report() {
    local report_file="$1"
    local report_date="$2"
    local recipients=("manager@company.com" "analyst@company.com")
    
    local subject="Daily Sales Report - $report_date"
    local body="Please find attached the daily sales report for $report_date.

Key highlights will be covered in tomorrow's meeting.

Best regards,
Automated Reporting System"
    
    for recipient in "${recipients[@]}"; do
        echo "$body" | mail -s "$subject" \
                           -a "$report_file" \
                           "$recipient"
        
        log_info "Report sent to $recipient"
    done
    
    # Upload to shared directory
    if [[ -d "/shared/reports" ]]; then
        cp "$report_file" "/shared/reports/daily_report_$report_date.html"
        chmod 644 "/shared/reports/daily_report_$report_date.html"
    fi
}

# Slack notification integration
send_slack_notification() {
    local webhook_url="$1"
    local report_summary="$2"
    local report_date="$3"
    
    local payload="{
        \"text\": \"📊 Daily Sales Report Available\",
        \"attachments\": [{
            \"color\": \"good\",
            \"fields\": [{
                \"title\": \"Report Date\",
                \"value\": \"$report_date\",
                \"short\": true
            }, {
                \"title\": \"Summary\",
                \"value\": \"$report_summary\",
                \"short\": false
            }]
        }]
    }"
    
    curl -X POST -H 'Content-type: application/json' \
         --data "$payload" "$webhook_url"
}
```

### File Processing Workflows

File processing workflows handle various file operations including transformation, validation, archival, and batch processing across different file formats and sizes.

#### Batch File Processing

Batch processing enables handling large volumes of files efficiently with parallel processing, error handling, and progress tracking capabilities.

```bash
# Parallel file processing with job control
process_files_parallel() {
    local source_dir="$1"
    local output_dir="$2"
    local max_jobs="${3:-4}"
    
    find "$source_dir" -name "*.csv" -print0 | \
    while IFS= read -r -d '' file; do
        # Wait for available job slot
        while (( $(jobs -r | wc -l) >= max_jobs )); do
            sleep 1
        done
        
        # Process file in background
        {
            process_single_file "$file" "$output_dir"
            if [[ $? -eq 0 ]]; then
                log_info "Successfully processed: $(basename "$file")"
            else
                log_error "Failed to process: $(basename "$file")"
            fi
        } &
    done
    
    # Wait for all jobs to complete
    wait
    log_info "Batch processing completed"
}

# File processing with validation and recovery
process_single_file() {
    local input_file="$1"
    local output_dir="$2"
    local filename=$(basename "$input_file" .csv)
    local output_file="$output_dir/${filename}_processed.csv"
    local error_file="$output_dir/${filename}_errors.log"
    
    # Validate file structure
    if ! validate_csv_structure "$input_file"; then
        echo "Invalid CSV structure" > "$error_file"
        return 1
    fi
    
    # Process with error tracking
    awk -F',' -v error_file="$error_file" '
    BEGIN { OFS="," }
    NR == 1 { print; next }  # Print header
    {
        # Validate required fields
        if (NF < 5) {
            print "Line " NR ": Insufficient fields" > error_file
            next
        }
        
        # Data cleaning and transformation
        gsub(/^[ \t]+|[ \t]+$/, "", $2)  # Trim whitespace
        if ($3 ~ /^[0-9]+(\.[0-9]{2})?$/) {
            $3 = sprintf("%.2f", $3)
            print
        } else {
            print "Line " NR ": Invalid price format" > error_file
        }
    }' "$input_file" > "$output_file"
    
    # Check if processing was successful
    if [[ -s "$error_file" ]]; then
        log_warning "Processing completed with errors: $error_file"
        return 1
    else
        rm -f "$error_file"
        return 0
    fi
}
```

#### File Format Conversion

File format conversion workflows handle transformation between different formats while preserving data integrity and handling encoding issues.

```bash
# Multi-format conversion pipeline
convert_file_formats() {
    local input_file="$1"
    local output_format="$2"
    local output_file="$3"
    
    local input_format=$(detect_file_format "$input_file")
    
    case "$input_format-$output_format" in
        "csv-json")
            convert_csv_to_json "$input_file" "$output_file"
            ;;
        "json-csv")
            convert_json_to_csv "$input_file" "$output_file"
            ;;
        "excel-csv")
            convert_excel_to_csv "$input_file" "$output_file"
            ;;
        "xml-json")
            convert_xml_to_json "$input_file" "$output_file"
            ;;
        *)
            log_error "Unsupported conversion: $input_format to $output_format"
            return 1
            ;;
    esac
}

# CSV to JSON conversion with nested structures
convert_csv_to_json() {
    local csv_file="$1"
    local json_file="$2"
    
    awk -F',' '
    BEGIN {
        print "["
        first = 1
    }
    NR == 1 {
        # Store headers
        for (i = 1; i <= NF; i++) {
            headers[i] = $i
        }
        next
    }
    {
        if (!first) print ","
        first = 0
        
        printf "  {"
        for (i = 1; i <= NF; i++) {
            if (i > 1) printf ","
            # Handle numeric vs string values
            if ($i ~ /^[0-9]+(\.[0-9]+)?$/) {
                printf "\"%s\":%s", headers[i], $i
            } else {
                gsub(/"/, "\\\"", $i)  # Escape quotes
                printf "\"%s\":\"%s\"", headers[i], $i
            }
        }
        printf "}"
    }
    END {
        print ""
        print "]"
    }' "$csv_file" > "$json_file"
}

# Excel to CSV conversion using python
convert_excel_to_csv() {
    local excel_file="$1"
    local csv_file="$2"
    
    python3 -c "
import pandas as pd
import sys

try:
    df = pd.read_excel('$excel_file')
    df.to_csv('$csv_file', index=False)
    print('Conversion successful')
except Exception as e:
    print(f'Conversion failed: {e}', file=sys.stderr)
    sys.exit(1)
"
}
```

#### Data Validation and Quality Control

Data validation ensures file integrity, format compliance, and business rule adherence throughout the processing pipeline.

```bash
# Comprehensive data validation framework
validate_data_quality() {
    local data_file="$1"
    local validation_rules="$2"
    local report_file="$3"
    
    echo "Data Quality Report - $(date)" > "$report_file"
    echo "File: $data_file" >> "$report_file"
    echo "================================" >> "$report_file"
    
    local total_errors=0
    
    # Check file accessibility
    if [[ ! -r "$data_file" ]]; then
        echo "ERROR: File not readable" >> "$report_file"
        return 1
    fi
    
    # Validate file structure
    local field_count=$(head -1 "$data_file" | tr ',' '\n' | wc -l)
    local inconsistent_rows=$(awk -F',' -v expected="$field_count" '
        NF != expected { print NR }
    ' "$data_file" | wc -l)
    
    if [[ $inconsistent_rows -gt 0 ]]; then
        echo "WARNING: $inconsistent_rows rows have inconsistent field count" >> "$report_file"
        ((total_errors++))
    fi
    
    # Apply business rules validation
    while IFS='|' read -r field_name validation_type validation_param; do
        case "$validation_type" in
            "required")
                validate_required_field "$data_file" "$field_name" >> "$report_file"
                ;;
            "numeric")
                validate_numeric_field "$data_file" "$field_name" >> "$report_file"
                ;;
            "date")
                validate_date_field "$data_file" "$field_name" "$validation_param" >> "$report_file"
                ;;
            "range")
                validate_range_field "$data_file" "$field_name" "$validation_param" >> "$report_file"
                ;;
        esac
    done < "$validation_rules"
    
    # Statistical summary
    echo "" >> "$report_file"
    echo "Statistical Summary:" >> "$report_file"
    echo "Total rows: $(wc -l < "$data_file")" >> "$report_file"
    echo "Data rows: $(($(wc -l < "$data_file") - 1))" >> "$report_file"
    echo "Validation errors: $total_errors" >> "$report_file"
    
    return $total_errors
}

# Field-specific validation functions
validate_required_field() {
    local file="$1"
    local field_name="$2"
    
    local field_index=$(head -1 "$file" | tr ',' '\n' | grep -n "^$field_name$" | cut -d: -f1)
    
    if [[ -z "$field_index" ]]; then
        echo "ERROR: Field '$field_name' not found"
        return 1
    fi
    
    local empty_count=$(awk -F',' -v field="$field_index" '
        NR > 1 && ($field == "" || $field ~ /^[ \t]*$/) { count++ }
        END { print count+0 }
    ' "$file")
    
    if [[ $empty_count -gt 0 ]]; then
        echo "ERROR: Field '$field_name' has $empty_count empty values"
        return 1
    else
        echo "PASS: Field '$field_name' required validation"
        return 0
    fi
}

validate_numeric_field() {
    local file="$1"
    local field_name="$2"
    
    local field_index=$(head -1 "$file" | tr ',' '\n' | grep -n "^$field_name$" | cut -d: -f1)
    
    local invalid_count=$(awk -F',' -v field="$field_index" '
        NR > 1 && $field !~ /^[0-9]+(\.[0-9]+)?$/ && $field != "" { count++ }
        END { print count+0 }
    ' "$file")
    
    if [[ $invalid_count -gt 0 ]]; then
        echo "ERROR: Field '$field_name' has $invalid_count non-numeric values"
        return 1
    else
        echo "PASS: Field '$field_name' numeric validation"
        return 0
    fi
}
```

### Integration with External Tools

Integration capabilities allow bash pipelines to interact with databases, APIs, cloud services, and other systems, creating comprehensive data processing ecosystems.

#### Database Integration

Database integration involves connecting to various database systems, executing queries, and handling transactions within bash scripts.

```bash
# Multi-database connection manager
init_database_connections() {
    # MySQL connection
    export MYSQL_CONN="mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_DB"
    
    # PostgreSQL connection
    export PGPASSWORD="$POSTGRES_PASS"
    export POSTGRES_CONN="psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB"
    
    # SQLite connection
    export SQLITE_CONN="sqlite3 $SQLITE_DB_PATH"
    
    # Test connections
    test_database_connections
}

execute_database_query() {
    local db_type="$1"
    local query="$2"
    local output_file="$3"
    
    case "$db_type" in
        "mysql")
            echo "$query" | $MYSQL_CONN --batch --raw > "$output_file" 2>/dev/null
            ;;
        "postgres")
            echo "$query" | $POSTGRES_CONN -t -A -F',' > "$output_file" 2>/dev/null
            ;;
        "sqlite")
            echo "$query" | $SQLITE_CONN -header -csv > "$output_file" 2>/dev/null
            ;;
        *)
            log_error "Unsupported database type: $db_type"
            return 1
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        log_info "Query executed successfully on $db_type"
        return 0
    else
        log_error "Query failed on $db_type"
        return 1
    fi
}

# Bulk data loading with transaction support
bulk_load_data() {
    local db_type="$1"
    local table_name="$2"
    local data_file="$3"
    local use_transaction="${4:-true}"
    
    case "$db_type" in
        "mysql")
            if [[ "$use_transaction" == "true" ]]; then
                {
                    echo "START TRANSACTION;"
                    echo "LOAD DATA LOCAL INFILE '$data_file' INTO TABLE $table_name FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
                    echo "COMMIT;"
                } | $MYSQL_CONN
            else
                echo "LOAD DATA LOCAL INFILE '$data_file' INTO TABLE $table_name FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;" | $MYSQL_CONN
            fi
            ;;
        "postgres")
            if [[ "$use_transaction" == "true" ]]; then
                {
                    echo "BEGIN;"
                    echo "\\copy $table_name FROM '$data_file' WITH CSV HEADER;"
                    echo "COMMIT;"
                } | $POSTGRES_CONN
            else
                echo "\\copy $table_name FROM '$data_file' WITH CSV HEADER;" | $POSTGRES_CONN
            fi
            ;;
    esac
}
```

#### API Integration

API integration enables bash scripts to interact with REST APIs, handle authentication, and process JSON responses effectively.

```bash
# RESTful API client with comprehensive error handling
api_client() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local output_file="$4"
    local headers=("${@:5}")
    
    local curl_opts=(
        --silent
        --show-error
        --fail
        --max-time 30
        --retry 3
        --retry-delay 2
        --write-out "%{http_code}|%{time_total}|%{size_download}"
    )
    
    # Add headers
    for header in "${headers[@]}"; do
        curl_opts+=(-H "$header")
    done
    
    # Add method-specific options
    case "$method" in
        "GET")
            curl_opts+=(-X GET)
            ;;
        "POST")
            curl_opts+=(-X POST -d "$data" -H "Content-Type: application/json")
            ;;
        "PUT")
            curl_opts+=(-X PUT -d "$data" -H "Content-Type: application/json")
            ;;
        "DELETE")
            curl_opts+=(-X DELETE)
            ;;
    esac
    
    # Execute request and capture metrics
    local response
    response=$(curl "${curl_opts[@]}" "$endpoint" 2>/dev/null)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Parse response and metrics
        local body="${response%|*|*|*}"
        local metrics="${response##*|}"
        
        echo "$body" > "$output_file"
        log_info "API request successful: $method $endpoint"
        log_debug "Response metrics: $metrics"
        return 0
    else
        log_error "API request failed: $method $endpoint (exit code: $exit_code)"
        return $exit_code
    fi
}

# OAuth 2.0 token management
manage_oauth_token() {
    local token_file="$HOME/.api_tokens/oauth_token"
    local refresh_token_file="$HOME/.api_tokens/refresh_token"
    
    # Check if token exists and is valid
    if [[ -f "$token_file" ]]; then
        local token_age=$(($(date +%s) - $(stat -f %m "$token_file" 2>/dev/null || stat -c %Y "$token_file")))
        if [[ $token_age -lt 3500 ]]; then  # Token valid for ~1 hour, refresh at 58 minutes
            cat "$token_file"
            return 0
        fi
    fi
    
    # Refresh token
    if [[ -f "$refresh_token_file" ]]; then
        local refresh_token
        refresh_token=$(cat "$refresh_token_file")
        
        local token_response
        token_response=$(curl -s -X POST "$OAUTH_TOKEN_ENDPOINT" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "grant_type=refresh_token&refresh_token=$refresh_token&client_id=$OAUTH_CLIENT_ID&client_secret=$OAUTH_CLIENT_SECRET")
        
        if [[ $? -eq 0 ]]; then
            local access_token
            access_token=$(echo "$token_response" | jq -r '.access_token')
            local new_refresh_token
            new_refresh_token=$(echo "$token_response" | jq -r '.refresh_token')
            
            echo "$access_token" > "$token_file"
            echo "$new_refresh_token" > "$refresh_token_file"
            chmod 600 "$token_file" "$refresh_token_file"
            
            echo "$access_token"
            return 0
        fi
    fi
    
    log_error "Failed to obtain valid OAuth token"
    return 1
}

# JSON processing with jq integration
process_api_response() {
    local json_file="$1"
    local jq_filter="$2"
    local output_file="$3"
    
    if [[ ! -f "$json_file" ]]; then
        log_error "JSON file not found: $json_file"
        return 1
    fi
    
    # Validate JSON format
    if ! jq empty "$json_file" 2>/dev/null; then
        log_error "Invalid JSON format in file: $json_file"
        return 1
    fi
    
    # Apply jq filter and save results
    jq -r "$jq_filter" "$json_file" > "$output_file"
    
    if [[ $? -eq 0 ]]; then
        log_info "JSON processing completed successfully"
        return 0
    else
        log_error "JSON processing failed with filter: $jq_filter"
        return 1
    fi
}
```

#### Cloud Service Integration

Cloud service integration enables bash pipelines to interact with AWS, Google Cloud, Azure, and other cloud platforms for storage, computing, and data processing services.

```bash
# AWS S3 integration with error handling and retry logic
s3_operations() {
    local operation="$1"
    local source="$2"
    local destination="$3"
    local options="${@:4}"
    
    case "$operation" in
        "upload")
            aws s3 cp "$source" "$destination" $options \
                --storage-class STANDARD_IA \
                --metadata "pipeline=data-processing,timestamp=$(date -u +%Y%m%d-%H%M%S)" \
                --no-progress 2>/dev/null
            ;;
        "download")
            aws s3 cp "$destination" "$source" $options \
                --no-progress 2>/dev/null
            ;;
        "sync")
            aws s3 sync "$source" "$destination" $options \
                --delete \
                --exclude "*.tmp" \
                --exclude ".DS_Store" \
                --no-progress 2>/dev/null
            ;;
        "list")
            aws s3 ls "$source" --recursive --human-readable --summarize
            ;;
    esac
    
    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        log_info "S3 $operation completed successfully"
        return 0
    else
        log_error "S3 $operation failed (exit code: $exit_code)"
        return $exit_code
    fi
}

# Google Cloud Storage integration
gcs_operations() {
    local operation="$1"
    local source="$2"
    local destination="$3"
    
    case "$operation" in
        "upload")
            gsutil -m cp -r "$source" "$destination" 2>/dev/null
            ;;
        "download")
            gsutil -m cp -r "$destination" "$source" 2>/dev/null
            ;;
        "sync")
            gsutil -m rsync -r -d "$source" "$destination" 2>/dev/null
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        log_info "GCS $operation completed successfully"
        return 0
    else
        log_error "GCS $operation failed"
        return 1
    fi
}

# Azure Blob Storage integration
azure_blob_operations() {
    local operation="$1"
    local container="$2"
    local blob_path="$3"
    local local_path="$4"
    
    case "$operation" in
        "upload")
            az storage blob upload \
                --container-name "$container" \
                --name "$blob_path" \
                --file "$local_path" \
                --auth-mode login \
                --output none 2>/dev/null
            ;;
        "download")
            az storage blob download \
                --container-name "$container" \
                --name "$blob_path" \
                --file "$local_path" \
                --auth-mode login \
                --output none 2>/dev/null
            ;;
        "list")
            az storage blob list \
                --container-name "$container" \
                --prefix "$blob_path" \
                --auth-mode login \
                --output table 2>/dev/null
            ;;
    esac
}
```

#### Message Queue Integration

Message queue integration allows pipelines to handle asynchronous processing, event-driven workflows, and distributed task processing.

```bash
# RabbitMQ integration with message handling
rabbitmq_operations() {
    local operation="$1"
    local queue_name="$2"
    local message="$3"
    
    local rabbitmq_url="amqp://$RABBITMQ_USER:$RABBITMQ_PASS@$RABBITMQ_HOST:5672/"
    
    case "$operation" in
        "publish")
            python3 -c "
import pika
import sys
import json

try:
    connection = pika.BlockingConnection(pika.URLParameters('$rabbitmq_url'))
    channel = connection.channel()
    
    channel.queue_declare(queue='$queue_name', durable=True)
    
    channel.basic_publish(
        exchange='',
        routing_key='$queue_name',
        body='$message',
        properties=pika.BasicProperties(delivery_mode=2)  # Make message persistent
    )
    
    connection.close()
    print('Message published successfully')
except Exception as e:
    print(f'Failed to publish message: {e}', file=sys.stderr)
    sys.exit(1)
"
            ;;
        "consume")
            python3 -c "
import pika
import sys

def callback(ch, method, properties, body):
    print(body.decode('utf-8'))
    ch.basic_ack(delivery_tag=method.delivery_tag)

try:
    connection = pika.BlockingConnection(pika.URLParameters('$rabbitmq_url'))
    channel = connection.channel()
    
    channel.queue_declare(queue='$queue_name', durable=True)
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue='$queue_name', on_message_callback=callback)
    
    channel.start_consuming()
except KeyboardInterrupt:
    channel.stop_consuming()
    connection.close()
except Exception as e:
    print(f'Failed to consume messages: {e}', file=sys.stderr)
    sys.exit(1)
"
            ;;
    esac
}

# Apache Kafka integration
kafka_operations() {
    local operation="$1"
    local topic="$2"
    local message="$3"
    
    case "$operation" in
        "produce")
            echo "$message" | kafka-console-producer \
                --bootstrap-server "$KAFKA_BOOTSTRAP_SERVERS" \
                --topic "$topic" \
                --property "parse.key=true" \
                --property "key.separator=:" 2>/dev/null
            ;;
        "consume")
            kafka-console-consumer \
                --bootstrap-server "$KAFKA_BOOTSTRAP_SERVERS" \
                --topic "$topic" \
                --from-beginning \
                --max-messages 1 \
                --timeout-ms 5000 2>/dev/null
            ;;
        "create_topic")
            kafka-topics \
                --bootstrap-server "$KAFKA_BOOTSTRAP_SERVERS" \
                --create \
                --topic "$topic" \
                --partitions 3 \
                --replication-factor 1 2>/dev/null
            ;;
    esac
}
```

### Pipeline Orchestration and Monitoring

Pipeline orchestration involves coordinating multiple processing steps, handling dependencies, and monitoring execution status with comprehensive logging and alerting systems.

#### Workflow Management

Workflow management systems coordinate complex multi-step processes with dependency resolution, parallel execution, and error recovery mechanisms.

```bash
# Pipeline orchestrator with dependency management
execute_pipeline() {
    local pipeline_config="$1"
    local execution_id="pipeline_$(date +%Y%m%d_%H%M%S)_$$"
    
    # Create execution workspace
    local workspace="/tmp/$execution_id"
    mkdir -p "$workspace"/{logs,data,temp}
    
    log_info "Starting pipeline execution: $execution_id"
    
    # Parse pipeline configuration
    declare -A steps tasks dependencies
    parse_pipeline_config "$pipeline_config" steps tasks dependencies
    
    # Execute pipeline steps
    local completed_steps=()
    local failed_steps=()
    
    while [[ ${#completed_steps[@]} -lt ${#steps[@]} ]]; do
        local progress_made=false
        
        for step_name in "${!steps[@]}"; do
            # Skip if already completed or failed
            if [[ " ${completed_steps[*]} " =~ " $step_name " ]] || \
               [[ " ${failed_steps[*]} " =~ " $step_name " ]]; then
                continue
            fi
            
            # Check if dependencies are satisfied
            if check_step_dependencies "$step_name" dependencies completed_steps; then
                log_info "Executing step: $step_name"
                
                # Execute step with timeout and logging
                execute_pipeline_step "$step_name" "${tasks[$step_name]}" "$workspace" &
                local step_pid=$!
                
                # Monitor step execution
                if monitor_step_execution "$step_pid" "$step_name" 300; then  # 5 minute timeout
                    completed_steps+=("$step_name")
                    log_info "Step completed successfully: $step_name"
                    progress_made=true
                else
                    failed_steps+=("$step_name")
                    log_error "Step failed: $step_name"
                    
                    # Check if step is critical
                    if [[ "${steps[$step_name]}" =~ "critical" ]]; then
                        log_error "Critical step failed, aborting pipeline"
                        cleanup_pipeline "$workspace"
                        return 1
                    fi
                fi
            fi
        done
        
        # Deadlock detection
        if [[ "$progress_made" == false ]]; then
            log_error "Pipeline deadlock detected - no progress made"
            cleanup_pipeline "$workspace"
            return 1
        fi
    done
    
    log_info "Pipeline execution completed: $execution_id"
    generate_execution_report "$execution_id" "$workspace" completed_steps failed_steps
    
    # Cleanup unless debug mode
    if [[ "$DEBUG_MODE" != "true" ]]; then
        cleanup_pipeline "$workspace"
    fi
    
    return 0
}

# Step dependency checker
check_step_dependencies() {
    local step_name="$1"
    local -n deps_ref=$2
    local -n completed_ref=$3
    
    local step_deps="${deps_ref[$step_name]}"
    
    if [[ -z "$step_deps" ]]; then
        return 0  # No dependencies
    fi
    
    IFS=',' read -ra dep_array <<< "$step_deps"
    for dep in "${dep_array[@]}"; do
        if [[ ! " ${completed_ref[*]} " =~ " $dep " ]]; then
            return 1  # Dependency not satisfied
        fi
    done
    
    return 0  # All dependencies satisfied
}

# Individual step execution with monitoring
execute_pipeline_step() {
    local step_name="$1"
    local step_command="$2"
    local workspace="$3"
    
    local step_log="$workspace/logs/${step_name}.log"
    local step_error="$workspace/logs/${step_name}.error"
    
    # Set up step environment
    export STEP_NAME="$step_name"
    export STEP_WORKSPACE="$workspace"
    export STEP_DATA_DIR="$workspace/data"
    export STEP_TEMP_DIR="$workspace/temp"
    
    # Execute step with comprehensive logging
    {
        echo "Step: $step_name"
        echo "Started: $(date)"
        echo "Command: $step_command"
        echo "========================"
        
        # Execute the actual step command
        eval "$step_command"
        local exit_code=$?
        
        echo "========================"
        echo "Completed: $(date)"
        echo "Exit code: $exit_code"
        
        return $exit_code
    } > "$step_log" 2> "$step_error"
}

# Step execution monitoring with timeout
monitor_step_execution() {
    local step_pid="$1"
    local step_name="$2"
    local timeout="$3"
    
    local elapsed=0
    local interval=5
    
    while [[ $elapsed -lt $timeout ]]; do
        if ! kill -0 "$step_pid" 2>/dev/null; then
            # Process completed
            wait "$step_pid"
            return $?
        fi
        
        sleep $interval
        elapsed=$((elapsed + interval))
        
        # Log progress every minute
        if [[ $((elapsed % 60)) -eq 0 ]]; then
            log_info "Step '$step_name' running for ${elapsed}s"
        fi
    done
    
    # Timeout reached
    log_warning "Step '$step_name' timeout reached, terminating"
    kill -TERM "$step_pid" 2>/dev/null
    sleep 5
    kill -KILL "$step_pid" 2>/dev/null
    
    return 1
}
```

#### Monitoring and Alerting

Comprehensive monitoring systems track pipeline performance, resource usage, and execution status with intelligent alerting mechanisms.

```bash
# Pipeline monitoring system
monitor_pipeline_health() {
    local monitoring_interval="${1:-60}"  # seconds
    local alert_threshold="${2:-80}"      # percentage
    
    while true; do
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local metrics_file="/var/log/pipeline_metrics.log"
        
        # Collect system metrics
        local cpu_usage
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
        
        local memory_usage
        memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        
        local disk_usage
        disk_usage=$(df /tmp | tail -1 | awk '{print $5}' | sed 's/%//')
        
        local active_processes
        active_processes=$(pgrep -f "pipeline_" | wc -l)
        
        # Log metrics
        echo "$timestamp,CPU:$cpu_usage,Memory:$memory_usage,Disk:$disk_usage,Processes:$active_processes" >> "$metrics_file"
        
        # Check alert thresholds
        check_alert_conditions "$cpu_usage" "$memory_usage" "$disk_usage" "$alert_threshold"
        
        # Monitor pipeline-specific metrics
        monitor_pipeline_queues
        monitor_error_rates
        
        sleep "$monitoring_interval"
    done
}

# Alert condition checker
check_alert_conditions() {
    local cpu_usage="$1"
    local memory_usage="$2"
    local disk_usage="$3"
    local threshold="$4"
    
    # CPU usage alert
    if (( $(echo "$cpu_usage > $threshold" | bc -l) )); then
        send_alert "HIGH_CPU" "CPU usage is ${cpu_usage}% (threshold: ${threshold}%)"
    fi
    
    # Memory usage alert
    if (( $(echo "$memory_usage > $threshold" | bc -l) )); then
        send_alert "HIGH_MEMORY" "Memory usage is ${memory_usage}% (threshold: ${threshold}%)"
    fi
    
    # Disk usage alert
    if [[ $disk_usage -gt $threshold ]]; then
        send_alert "HIGH_DISK" "Disk usage is ${disk_usage}% (threshold: ${threshold}%)"
    fi
    
    # Process count alert
    local max_processes=50
    local current_processes=$(pgrep -f "pipeline_" | wc -l)
    if [[ $current_processes -gt $max_processes ]]; then
        send_alert "HIGH_PROCESS_COUNT" "Active pipeline processes: $current_processes (max: $max_processes)"
    fi
}

# Queue monitoring for message-based pipelines
monitor_pipeline_queues() {
    local queue_names=("data_processing" "report_generation" "file_conversion")
    
    for queue in "${queue_names[@]}"; do
        local queue_depth
        queue_depth=$(rabbitmqctl list_queues name messages 2>/dev/null | grep "^$queue" | awk '{print $2}')
        
        if [[ -n "$queue_depth" ]] && [[ $queue_depth -gt 1000 ]]; then
            send_alert "QUEUE_BACKLOG" "Queue '$queue' has $queue_depth messages pending"
        fi
    done
}

# Error rate monitoring
monitor_error_rates() {
    local log_file="/var/log/pipeline.log"
    local time_window=300  # 5 minutes in seconds
    local error_threshold=10
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    # Count errors in the last 5 minutes
    local recent_errors
    recent_errors=$(awk -v window="$time_window" '
    BEGIN {
        cmd = "date +%s"
        cmd | getline current_time
        close(cmd)
        cutoff = current_time - window
    }
    {
        # Parse timestamp (assuming ISO format)
        if (match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/)) {
            timestamp_str = substr($0, RSTART, RLENGTH)
            cmd = "date -d \"" timestamp_str "\" +%s"
            cmd | getline timestamp
            close(cmd)
            
            if (timestamp >= cutoff && /ERROR/) {
                errors++
            }
        }
    }
    END { print errors+0 }' "$log_file")
    
    if [[ $recent_errors -gt $error_threshold ]]; then
        send_alert "HIGH_ERROR_RATE" "Pipeline error rate: $recent_errors errors in last 5 minutes"
    fi
}

# Alert dispatcher with multiple channels
send_alert() {
    local alert_type="$1"
    local alert_message="$2"
    local severity="${3:-WARNING}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log alert
    echo "[$timestamp] ALERT [$severity] $alert_type: $alert_message" >> /var/log/pipeline_alerts.log
    
    # Email notification
    if [[ -n "$ALERT_EMAIL" ]]; then
        echo "Pipeline Alert - $alert_type

Timestamp: $timestamp
Severity: $severity
Message: $alert_message

System: $(hostname)
Pipeline: Data Processing Pipeline" | \
        mail -s "Pipeline Alert: $alert_type" "$ALERT_EMAIL"
    fi
    
    # Slack notification
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        local color="warning"
        [[ "$severity" == "CRITICAL" ]] && color="danger"
        [[ "$severity" == "INFO" ]] && color="good"
        
        curl -X POST "$SLACK_WEBHOOK_URL" \
             -H 'Content-type: application/json' \
             --data "{
                 \"attachments\": [{
                     \"color\": \"$color\",
                     \"title\": \"Pipeline Alert: $alert_type\",
                     \"text\": \"$alert_message\",
                     \"fields\": [{
                         \"title\": \"Severity\",
                         \"value\": \"$severity\",
                         \"short\": true
                     }, {
                         \"title\": \"System\",
                         \"value\": \"$(hostname)\",
                         \"short\": true
                     }]
                 }]
             }" 2>/dev/null
    fi
    
    # PagerDuty integration for critical alerts
    if [[ "$severity" == "CRITICAL" ]] && [[ -n "$PAGERDUTY_INTEGRATION_KEY" ]]; then
        curl -X POST https://events.pagerduty.com/v2/enqueue \
             -H 'Content-Type: application/json' \
             -d "{
                 \"routing_key\": \"$PAGERDUTY_INTEGRATION_KEY\",
                 \"event_action\": \"trigger\",
                 \"payload\": {
                     \"summary\": \"Pipeline Alert: $alert_type\",
                     \"source\": \"$(hostname)\",
                     \"severity\": \"critical\",
                     \"custom_details\": {
                         \"message\": \"$alert_message\",
                         \"timestamp\": \"$timestamp\"
                     }
                 }
             }" 2>/dev/null
    fi
}

# Performance metrics collector
collect_performance_metrics() {
    local output_file="$1"
    local duration="${2:-3600}"  # 1 hour default
    
    echo "timestamp,cpu_percent,memory_percent,disk_io_read,disk_io_write,network_rx,network_tx" > "$output_file"
    
    local end_time=$(($(date +%s) + duration))
    
    while [[ $(date +%s) -lt $end_time ]]; do
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # CPU usage
        local cpu_percent
        cpu_percent=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        
        # Memory usage
        local memory_percent
        memory_percent=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        
        # Disk I/O
        local disk_stats
        disk_stats=$(iostat -d 1 2 | tail -n +4 | awk 'END {print $3","$4}')
        
        # Network I/O
        local network_stats
        network_stats=$(cat /proc/net/dev | grep eth0 | awk '{print $2","$10}')
        
        echo "$timestamp,$cpu_percent,$memory_percent,$disk_stats,$network_stats" >> "$output_file"
        
        sleep 60  # Collect every minute
    done
}
```

**Key points:**

- Data processing pipelines in bash provide robust ETL capabilities with comprehensive error handling and monitoring
- ETL operations leverage bash's text processing strengths with tools like awk, sed, and cut for complex transformations
- Report generation automation includes data collection, analysis, formatting, and distribution through multiple channels
- File processing workflows handle batch operations, format conversion, and data validation with parallel processing capabilities
- Integration with external systems enables comprehensive data ecosystems spanning databases, APIs, cloud services, and message queues
- Pipeline orchestration coordinates complex workflows with dependency management and failure recovery
- Monitoring and alerting systems provide real-time visibility into pipeline health and performance metrics

**Important subtopics for advanced implementation:**

- Security considerations including credential management, data encryption, and access control
- Performance optimization techniques for large-scale data processing
- Disaster recovery and backup strategies for pipeline infrastructure
- Testing frameworks for data pipeline validation and quality assurance
