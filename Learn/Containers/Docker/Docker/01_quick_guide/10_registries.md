## Registries


### Docker Hub

Docker Hub is the default public registry. Images without a registry prefix (e.g., `nginx`, `postgres`) are pulled from Docker Hub.

```bash
# Log in
docker login

# Tag for Docker Hub
docker tag myapp:1.0 yourusername/myapp:1.0

# Push
docker push yourusername/myapp:1.0
```

### Private Registry

Run a local registry:

```bash
docker run -d -p 5000:5000 --name registry registry:2

docker tag myapp:1.0 localhost:5000/myapp:1.0
docker push localhost:5000/myapp:1.0
docker pull localhost:5000/myapp:1.0
```

### Cloud Registries

Major cloud providers offer managed registries. The workflow is the same: authenticate, tag with the registry URL, then push/pull.

```bash
# Amazon ECR example
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
docker tag myapp:1.0 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0
```

---

