## Memory and CPU Considerations


### Memory Optimization

- **State file size**: Large state files consume more memory
- **Provider memory usage**: Some providers cache more data than others
- **Concurrent operations**: Each parallel operation uses additional memory

### Memory Configuration

```bash
# Increase Go runtime memory limit
export GOMEMLIMIT=2GiB

# Monitor memory usage during operations
terraform apply -parallelism=5  # Reduce if memory constrained
```

### CPU Optimization

- **Parallelism tuning**: Balance between speed and resource usage
- **Provider efficiency**: Some providers are more CPU-intensive
- **Plan complexity**: Complex expressions require more CPU

### Resource Monitoring

```bash
# Monitor Terraform process
top -p $(pgrep terraform)

# Memory usage tracking
/usr/bin/time -v terraform apply
```

### Hardware Recommendations

**For Large Deployments:**

- **Memory**: 8GB+ RAM (16GB+ for very large state files)
- **CPU**: Multi-core processors (4+ cores recommended)
- **Storage**: SSD for local state and plan files
- **Network**: High bandwidth for remote state operations

