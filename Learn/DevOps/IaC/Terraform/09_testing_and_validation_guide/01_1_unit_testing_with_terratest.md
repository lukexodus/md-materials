## 1. Unit Testing with Terratest


### What is Terratest?

Terratest is a Go testing library that provides patterns and helper functions for testing infrastructure code. It allows you to write automated tests that deploy real infrastructure and validate it works correctly.

### Basic Setup

```go
// test/terraform_example_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformBasicExample(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../examples/basic",
        Vars: map[string]interface{}{
            "instance_name": "terratest-example",
            "instance_type": "t2.micro",
        },
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    instanceId := terraform.Output(t, terraformOptions, "instance_id")
    publicIp := terraform.Output(t, terraformOptions, "public_ip")
    
    assert.NotEmpty(t, instanceId)
    assert.Regexp(t, `^i-[a-zA-Z0-9]+$`, instanceId)
    assert.Regexp(t, `^\d+\.\d+\.\d+\.\d+$`, publicIp)
}
```

### Advanced Terratest Patterns

```go
func TestTerraformWithRetries(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/web-server",
        RetryableTerraformErrors: map[string]string{
            "RequestError: send request failed": "Temporary AWS API error",
        },
        MaxRetries:         3,
        TimeBetweenRetries: 5 * time.Second,
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Test HTTP endpoint
    url := terraform.Output(t, terraformOptions, "url")
    http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 5*time.Second)
}
```

### Testing Multiple Environments

```go
func TestTerraformMultipleEnvironments(t *testing.T) {
    environments := []string{"dev", "staging", "prod"}
    
    for _, env := range environments {
        env := env // capture range variable
        t.Run(env, func(t *testing.T) {
            t.Parallel()
            
            terraformOptions := &terraform.Options{
                TerraformDir: "../environments/" + env,
                VarFiles: []string{"../config/" + env + ".tfvars"},
            }
            
            defer terraform.Destroy(t, terraformOptions)
            terraform.InitAndApply(t, terraformOptions)
            
            // Environment-specific validations
            validateEnvironment(t, terraformOptions, env)
        })
    }
}
```

