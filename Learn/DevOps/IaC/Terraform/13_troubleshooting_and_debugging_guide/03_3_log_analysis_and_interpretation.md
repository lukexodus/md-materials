## 3. Log Analysis and Interpretation


### Understanding Terraform Logs

#### Log Level Hierarchy

```
TRACE > DEBUG > INFO > WARN > ERROR
```

#### Common Log Patterns

```bash
# Provider initialization
2023-07-28T10:00:00.000Z [DEBUG] provider.terraform-provider-aws: configuring client

# Resource planning
2023-07-28T10:00:01.000Z [TRACE] dag/walk: walking "aws_instance.web"
2023-07-28T10:00:01.000Z [DEBUG] aws_instance.web: planning...

# API calls
2023-07-28T10:00:02.000Z [DEBUG] provider.terraform-provider-aws: making API call: RunInstances

# Errors
2023-07-28T10:00:03.000Z [ERROR] aws_instance.web: error creating instance: InvalidAMIID.NotFound
```

### Analyzing Provider Logs

```bash
# Example AWS provider debug output analysis
grep "HTTP Request" terraform.log    # API requests
grep "HTTP Response" terraform.log   # API responses
grep "ERROR" terraform.log          # Error messages
grep "Rate limited" terraform.log   # Rate limiting issues

# Look for specific patterns
grep -A 5 -B 5 "InvalidAMIID" terraform.log  # Context around AMI errors
```

### Log Parsing Script

```bash
#!/bin/bash
# parse_tf_logs.sh

LOG_FILE=${1:-terraform.log}

echo "=== Error Summary ==="
grep "\[ERROR\]" "$LOG_FILE" | cut -d' ' -f4- | sort | uniq -c

echo -e "\n=== Warning Summary ==="
grep "\[WARN\]" "$LOG_FILE" | cut -d' ' -f4- | sort | uniq -c

echo -e "\n=== API Call Summary ==="
grep "making API call" "$LOG_FILE" | awk '{print $NF}' | sort | uniq -c

echo -e "\n=== Resource Operations ==="
grep -E "(Creating|Updating|Destroying)" "$LOG_FILE" | awk '{print $4, $5}' | sort | uniq -c
```

