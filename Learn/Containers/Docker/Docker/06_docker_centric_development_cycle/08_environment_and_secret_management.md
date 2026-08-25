## Environment and Secret Management


### Development: .env Files

Compose automatically reads a `.env` file in the project directory for variable substitution in `compose.yaml`. Keep `.env` out of version control.

```
POSTGRES_PASSWORD=devpassword
APP_SECRET_KEY=localdevkey
```

### Production: Secrets

Hardcoding secrets in environment variables is a common practice but carries risk since they appear in process listings and container inspection output. Better alternatives include:

- Docker Swarm secrets or Kubernetes secrets (mounted as files inside the container)
- External secret managers (HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager)
- BuildKit `--secret` for build-time secrets that do not persist in image layers

```bash
# Build-time secret example (secret never baked into image)
docker build --secret id=npmrc,src=$HOME/.npmrc .
```

---

