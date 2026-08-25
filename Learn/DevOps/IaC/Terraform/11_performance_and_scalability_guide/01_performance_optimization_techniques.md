## Performance Optimization Techniques


### Resource Configuration Best Practices

- **Minimize API calls**: Group related resources in modules to reduce provider API round trips
- **Use data sources efficiently**: Cache data source results when possible, avoid repeated lookups
- **Optimize resource dependencies**: Use explicit `depends_on` only when necessary
- **Provider version pinning**: Pin provider versions to avoid compatibility checks during initialization

### Module Design Patterns

- **Granular modules**: Create small, focused modules rather than monolithic ones
- **Resource grouping**: Group resources with similar lifecycles together
- **Input validation**: Use variable validation to catch errors early in the planning phase
- **Output optimization**: Only expose necessary outputs to reduce state complexity

### Provider-Specific Optimizations

- **AWS**: Use `aws_caller_identity` data source sparingly
- **Azure**: Leverage resource group scoping for faster API responses
- **GCP**: Use project-scoped resources when possible

