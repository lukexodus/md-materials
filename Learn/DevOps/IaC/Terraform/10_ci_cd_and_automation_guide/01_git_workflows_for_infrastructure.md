## Git Workflows for Infrastructure


### GitFlow for Infrastructure

```
main (production)
├── develop (staging)
├── feature/vpc-update
├── hotfix/security-patch
└── release/v1.2.0
```

**Branch Strategy:**

- `main`: Production-ready infrastructure
- `develop`: Integration branch for staging
- `feature/*`: Individual infrastructure changes
- `hotfix/*`: Emergency production fixes
- `release/*`: Preparation for production deployment

### Environment Branching

```
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── modules/
    ├── vpc/
    ├── ec2/
    └── rds/
```

**Best Practices:**

- Separate directories for environments
- Shared modules for reusability
- Environment-specific variable files
- Protected branches for production

