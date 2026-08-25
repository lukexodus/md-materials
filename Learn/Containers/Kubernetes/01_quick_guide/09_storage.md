## Storage


### Volume Types

Kubernetes supports many volume types. Common ones:

|Type|Description|
|---|---|
|`emptyDir`|Temporary storage tied to Pod lifetime|
|`hostPath`|Mounts a path from the host node's filesystem|
|`configMap`|Mounts ConfigMap keys as files|
|`secret`|Mounts Secret keys as files|
|`persistentVolumeClaim`|Mounts a PersistentVolume|
|`nfs`|NFS share|
|`csi`|Container Storage Interface driver (cloud volumes, etc.)|

### PersistentVolume and PersistentVolumeClaim

PersistentVolumes (PV) are cluster-level storage resources provisioned by an administrator or dynamically by a StorageClass. PersistentVolumeClaims (PVC) are requests for storage by a user.

```yaml
# PersistentVolume (static provisioning)
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/my-pv
```

```yaml
# PersistentVolumeClaim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

```yaml
# Using the PVC in a Pod
spec:
  containers:
    - name: app
      image: my-app:1.0
      volumeMounts:
        - name: storage
          mountPath: /data
  volumes:
    - name: storage
      persistentVolumeClaim:
        claimName: my-pvc
```

### Access Modes

|Mode|Abbreviation|Description|
|---|---|---|
|ReadWriteOnce|RWO|Mounted read-write by a single node|
|ReadOnlyMany|ROX|Mounted read-only by many nodes|
|ReadWriteMany|RWX|Mounted read-write by many nodes|
|ReadWriteOncePod|RWOP|Mounted read-write by a single Pod (K8s >= 1.22)|

### StorageClass and Dynamic Provisioning

StorageClasses define how storage is dynamically provisioned:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  fsType: ext4
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

Reference a StorageClass in a PVC for dynamic provisioning:

```yaml
spec:
  storageClassName: fast
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```

---

