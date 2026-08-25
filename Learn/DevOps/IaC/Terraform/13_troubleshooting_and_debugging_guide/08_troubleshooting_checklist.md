## Troubleshooting Checklist


### Pre-Deployment Checks

- [ ] Run `terraform validate`
- [ ] Run `terraform fmt -check`
- [ ] Execute `terraform plan` and review changes
- [ ] Verify authentication and permissions
- [ ] Check resource quotas and limits
- [ ] Backup current state

### During Issues

- [ ] Enable debug logging (`TF_LOG=DEBUG`)
- [ ] Check Terraform and provider versions
- [ ] Verify network connectivity
- [ ] Check API rate limits
- [ ] Review IAM permissions
- [ ] Examine state file for inconsistencies

### Post-Failure Recovery

- [ ] Document the failure and resolution
- [ ] Update runbooks and procedures
- [ ] Review monitoring and alerting
- [ ] Consider infrastructure changes to prevent recurrence
- [ ] Update team knowledge base

