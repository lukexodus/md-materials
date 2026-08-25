## Performance Monitoring and Troubleshooting


### Timing Analysis

```bash
# Enable detailed timing
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Analyze timing patterns
grep "timing" terraform.log | sort -k3 -n
```

### Common Performance Bottlenecks

1. **Large state files**: Split into smaller, focused workspaces
2. **Slow providers**: Check provider documentation for optimization tips
3. **Complex dependencies**: Simplify resource relationships
4. **Network latency**: Use regional backends close to execution environment

### Performance Testing

```bash
# Benchmark different parallelism settings
time terraform apply -parallelism=5
time terraform apply -parallelism=10
time terraform apply -parallelism=20
```

