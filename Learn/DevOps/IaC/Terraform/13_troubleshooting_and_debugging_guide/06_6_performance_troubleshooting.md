## 6. Performance Troubleshooting


### Identifying Performance Bottlenecks

#### Plan Performance Issues

```bash
# Measure plan time with different parallelism
time terraform plan -parallelism=1
time terraform plan -parallelism=10
time terraform plan -parallelism=50

# Profile plan operations
TF_LOG=DEBUG terraform plan 2>&1 | grep -E "(duration|took)"
```

#### Large State File Issues

```bash
# Analyze state file size and complexity
du -h terraform.tfstate
jq '.resources | length' terraform.tfstate
jq '.resources | group_by(.type) | map({type: .[0].type, count: length})' terraform.tfstate

# Split large configurations into smaller modules
# Use data sources instead of resource references where possible
```

### Memory and Resource Optimization

```bash
# Monitor Terraform memory usage
/usr/bin/time -v terraform plan

# For large deployments:
# 1. Increase system memory
# 2. Use smaller parallelism values
# 3. Split into multiple state files
# 4. Use targeted operations
terraform plan -target=module.compute
```

### Network Performance Issues

```bash
# Test provider API connectivity
curl -w "@curl-format.txt" -s -o /dev/null https://ec2.us-west-2.amazonaws.com

# curl-format.txt content:
#     time_namelookup:  %{time_namelookup}\n
#        time_connect:  %{time_connect}\n
#     time_appconnect:  %{time_appconnect}\n
#    time_pretransfer:  %{time_pretransfer}\n
#       time_redirect:  %{time_redirect}\n
#  time_starttransfer:  %{time_starttransfer}\n
#                     ----------\n
#          time_total:  %{time_total}\n
```

