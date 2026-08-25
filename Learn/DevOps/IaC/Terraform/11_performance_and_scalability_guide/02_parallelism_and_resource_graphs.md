## Parallelism and Resource Graphs


### Understanding Terraform's Resource Graph

Terraform builds a directed acyclic graph (DAG) of resources based on:

- Explicit dependencies (`depends_on`)
- Implicit dependencies (resource references)
- Provider constraints

### Parallelism Configuration

```bash
# Default parallelism is 10
terraform apply -parallelism=20

# Environment variable
export TF_CLI_ARGS_apply="-parallelism=15"
```

### Optimizing Resource Dependencies

- **Minimize cross-resource dependencies**: Design resources to be as independent as possible
- **Use locals for computed values**: Reduce dependency chains
- **Avoid unnecessary depends_on**: Let Terraform infer dependencies automatically

### Resource Graph Analysis

```bash
# Generate visual dependency graph
terraform graph | dot -Tpng > graph.png

# Show resource dependencies
terraform show -json | jq '.planned_values.root_module.resources'
```

