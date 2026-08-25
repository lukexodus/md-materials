## 7. Performance Testing for Large Deployments


### Performance Test Setup

```go
func TestLargeDeploymentPerformance(t *testing.T) {
    startTime := time.Now()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/large-deployment",
        Vars: map[string]interface{}{
            "instance_count": 100,
            "parallelism": 10,
        },
        PlanFilePath: "large-deployment.tfplan",
    }
    
    // Measure plan time
    planStart := time.Now()
    terraform.InitAndPlan(t, terraformOptions)
    planDuration := time.Since(planStart)
    
    // Measure apply time
    applyStart := time.Now()
    terraform.Apply(t, terraformOptions)
    applyDuration := time.Since(applyStart)
    
    defer func() {
        destroyStart := time.Now()
        terraform.Destroy(t, terraformOptions)
        destroyDuration := time.Since(destroyStart)
        
        t.Logf("Performance metrics:")
        t.Logf("Plan duration: %v", planDuration)
        t.Logf("Apply duration: %v", applyDuration)
        t.Logf("Destroy duration: %v", destroyDuration)
        t.Logf("Total duration: %v", time.Since(startTime))
    }()
    
    // Performance assertions
    assert.Less(t, planDuration, 10*time.Minute, "Plan should complete within 10 minutes")
    assert.Less(t, applyDuration, 30*time.Minute, "Apply should complete within 30 minutes")
}
```

### State Management Performance

```bash
#!/bin/bash
# performance-test.sh

# Test state operations with large state file
echo "Testing state operations..."

# Measure state list time
time terraform state list > /dev/null

# Measure state show time for random resource
RESOURCE=$(terraform state list | shuf -n 1)
time terraform state show "$RESOURCE" > /dev/null

# Measure refresh time
time terraform refresh > /dev/null

# Test with different parallelism settings
for parallelism in 5 10 20 50; do
    echo "Testing with parallelism: $parallelism"
    time terraform plan -parallelism=$parallelism -out="plan-$parallelism.tfplan" > /dev/null
done
```

### Memory and Resource Monitoring

```go
func TestMemoryUsage(t *testing.T) {
    // Monitor memory usage during large deployments
    var memStats runtime.MemStats
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/memory-intensive",
    }
    
    runtime.GC()
    runtime.ReadMemStats(&memStats)
    initialMem := memStats.Alloc
    
    terraform.InitAndApply(t, terraformOptions)
    defer terraform.Destroy(t, terraformOptions)
    
    runtime.GC()
    runtime.ReadMemStats(&memStats)
    finalMem := memStats.Alloc
    
    memoryIncrease := finalMem - initialMem
    t.Logf("Memory increase during test: %d bytes", memoryIncrease)
    
    // Assert memory usage is reasonable (example: less than 1GB increase)
    assert.Less(t, memoryIncrease, uint64(1024*1024*1024), 
        "Memory usage should not increase by more than 1GB")
}
```

