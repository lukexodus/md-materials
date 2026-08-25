## Terraform Import Command


The `terraform import` command associates existing infrastructure with Terraform resources:

```bash
terraform import resource_type.resource_name resource_id
```

Key considerations:

- Only imports the resource into state, not the configuration
- Requires manual creation of corresponding configuration blocks
- Different resource types use different identifier formats
- Some resources cannot be imported due to API limitations
- Import operations modify state files and should be carefully planned

