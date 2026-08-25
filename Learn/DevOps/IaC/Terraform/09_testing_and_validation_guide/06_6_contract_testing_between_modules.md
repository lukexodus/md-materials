## 6. Contract Testing Between Modules


### Module Interface Testing

```go
// test/module_contract_test.go
func TestModuleContract(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/networking",
        Vars: map[string]interface{}{
            "cidr_block": "10.0.0.0/16",
            "environment": "test",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Test required outputs exist
    requiredOutputs := []string{
        "vpc_id",
        "public_subnet_ids",
        "private_subnet_ids",
        "vpc_cidr_block",
    }
    
    for _, output := range requiredOutputs {
        value := terraform.Output(t, terraformOptions, output)
        assert.NotEmpty(t, value, "Output %s should not be empty", output)
    }
    
    // Test output formats
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.Regexp(t, `^vpc-[a-zA-Z0-9]+$`, vpcId)
    
    subnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
    assert.GreaterOrEqual(t, len(subnetIds), 2, "Should create at least 2 public subnets")
    
    for _, subnetId := range subnetIds {
        assert.Regexp(t, `^subnet-[a-zA-Z0-9]+$`, subnetId)
    }
}
```

### Module Compatibility Testing

```hcl
# test/compatibility/main.tf
module "networking" {
  source = "../../modules/networking"
  
  cidr_block  = "10.0.0.0/16"
  environment = "test"
}

module "compute" {
  source = "../../modules/compute"
  
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.networking.default_security_group_id]
}

# Test that modules work together
output "integration_test" {
  value = {
    vpc_id      = module.networking.vpc_id
    instance_id = module.compute.instance_id
    # This should not error if modules are compatible
    test_passed = length(module.compute.instance_id) > 0
  }
}
```

