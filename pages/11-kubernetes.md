---
routeAlias: 'kubernetes'
---

<a name="KUBERNETES" id="KUBERNETES"></a>

# Introduction to Kubernetes

## What is Kubernetes?

Kubernetes is an open-source container orchestration system that automates the deployment, scaling, and management of containerized applications.

---
# Core concepts

- **Pod** : Smallest deployable unit
- **Service** : Stable entry point for pods
- **Deployment** : Manages pod replicas
- **ConfigMap** : Application configuration
- **Secret** : Sensitive data

---
# Kubernetes architecture

## Main components
- **Master Node** : Control plane
- **Worker Node** : Runs containers
- **kubelet** : Agent on each node
- **kubectl** : Command-line interface

---
# Deployment example

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
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

---
# Kubernetes commands

```bash
# List pods
kubectl get pods

# Create a deployment
kubectl apply -f deployment.yaml

# View logs
kubectl logs pod-name

# Delete a deployment
kubectl delete deployment nginx-deployment
```

---
# Kubernetes benefits

- Automatic orchestration
- Horizontal scalability
- Self-healing
- Secret management
- Rolling updates
- Load balancing
