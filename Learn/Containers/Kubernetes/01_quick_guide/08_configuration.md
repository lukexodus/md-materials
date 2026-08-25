## Configuration


### ConfigMap

ConfigMaps store non-sensitive configuration data as key-value pairs.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  APP_ENV: production
  LOG_LEVEL: info
  config.yaml: |
    server:
      port: 8080
      timeout: 30s
```

Using a ConfigMap in a Pod:

```yaml
spec:
  containers:
    - name: app
      image: my-app:1.0
      # As environment variables
      envFrom:
        - configMapRef:
            name: my-config
      # Individual keys as env vars
      env:
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: my-config
              key: LOG_LEVEL
      # As a mounted volume (file)
      volumeMounts:
        - name: config-volume
          mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: my-config
```

### Secret

Secrets store sensitive data such as passwords, tokens, and keys. Values are base64-encoded at rest in etcd (but not encrypted by default — enable encryption at rest for production clusters).

```bash
# Create from literal values
kubectl create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=s3cr3t

# Create from a file
kubectl create secret generic tls-secret \
  --from-file=tls.crt=./cert.pem \
  --from-file=tls.key=./key.pem

# Create a TLS secret directly
kubectl create secret tls my-tls-secret \
  --cert=./cert.pem \
  --key=./key.pem
```

YAML definition (values must be base64-encoded):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: YWRtaW4=     # echo -n 'admin' | base64
  password: czNjcjN0     # echo -n 's3cr3t' | base64
```

Using a Secret in a Pod:

```yaml
spec:
  containers:
    - name: app
      image: my-app:1.0
      envFrom:
        - secretRef:
            name: my-secret
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: my-secret
              key: password
      volumeMounts:
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: my-secret
```

---

