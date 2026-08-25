## 2. Integration Testing Strategies


### Cross-Module Testing

```go
func TestNetworkingAndCompute(t *testing.T) {
    // Deploy networking first
    networkOptions := &terraform.Options{
        TerraformDir: "../modules/networking",
    }
    defer terraform.Destroy(t, networkOptions)
    terraform.InitAndApply(t, networkOptions)

    // Get networking outputs
    vpcId := terraform.Output(t, networkOptions, "vpc_id")
    subnetIds := terraform.OutputList(t, networkOptions, "subnet_ids")

    // Deploy compute using networking outputs
    computeOptions := &terraform.Options{
        TerraformDir: "../modules/compute",
        Vars: map[string]interface{}{
            "vpc_id":     vpcId,
            "subnet_ids": subnetIds,
        },
    }
    defer terraform.Destroy(t, computeOptions)
    terraform.InitAndApply(t, computeOptions)

    // Validate integration
    instanceId := terraform.Output(t, computeOptions, "instance_id")
    validateInstanceInVPC(t, instanceId, vpcId)
}
```

### End-to-End Testing

```go
func TestCompleteInfrastructure(t *testing.T) {
    // Deploy complete stack
    terraformOptions := &terraform.Options{
        TerraformDir: "../complete-example",
        VarFiles: []string{"test.tfvars"},
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Test application functionality
    loadBalancerUrl := terraform.Output(t, terraformOptions, "load_balancer_url")
    
    // Test health endpoints
    http_helper.HttpGetWithRetry(t, loadBalancerUrl+"/health", nil, 200, "OK", 30, 5*time.Second)
    
    // Test database connectivity
    dbEndpoint := terraform.Output(t, terraformOptions, "database_endpoint")
    validateDatabaseConnectivity(t, dbEndpoint)
    
    // Test auto-scaling
    validateAutoScaling(t, terraformOptions)
}
```

