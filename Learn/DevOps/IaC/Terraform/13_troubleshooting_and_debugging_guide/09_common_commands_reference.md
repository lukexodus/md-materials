## Common Commands Reference


```bash
# Diagnostic commands
terraform version
terraform providers
terraform validate
terraform fmt -check -diff

# State management
terraform state list
terraform state show RESOURCE
terraform state mv SOURCE DEST
terraform state rm RESOURCE
terraform import ADDR ID

# Recovery commands
terraform refresh
terraform apply -refresh-only
terraform force-unlock LOCK_ID
terraform workspace list

# Debugging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform console
terraform graph | dot -Tpng > graph.png
```

Remember: Always backup your state file before making significant changes, and test recovery procedures in non-production environments first.

---

