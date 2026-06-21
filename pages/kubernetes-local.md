---
layout: default
routeAlias: 'kubernetes-local'
---

# Kubernetes Local Multi-Node 🌐

## Installation and Configuration

- **Prerequisites**
  - Docker Desktop
  - kubectl
  - kind or minikube

- **Configuration**
  ```bash
  # Create a multi-node cluster with kind
  kind create cluster --config multi-node-config.yaml
  ```

- **Verification**
  ```bash
  # Check nodes
  kubectl get nodes
  ```

---
layout: default
routeAlias: 'kubernetes-local-config'
---

# Cluster Configuration

## kind configuration example

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
- role: worker
- role: worker
```

## Application deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

---
layout: default
routeAlias: 'kubernetes-local-networking'
---

# Networking and Services

## Network configuration

- **Services**
  - ClusterIP
  - NodePort
  - LoadBalancer

- **Ingress**
  - Nginx Ingress Controller
  - Traefik
  - Cert-Manager

## Service example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30000
  selector:
    app: nginx
```

---
layout: default
routeAlias: 'kubernetes-local-storage'
---

# Storage and Volumes

## Storage types

- **Persistent volumes**
  - HostPath
  - NFS
  - Cloud Storage

- **Storage Classes**
  - Standard
  - SSD
  - Premium

## PVC example

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
```
