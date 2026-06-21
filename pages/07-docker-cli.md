---
layout: new-section
routeAlias: 'le-cli-docker'
---

<a name="le-cli-docker" id="le-cli-docker"></a>

# The Docker CLI

---

# The Docker CLI 🖥️

### Your daily work tool

The **Docker CLI** is your main interface for interacting with Docker. Let's master the essential commands to be productive every day.

---

# Command structure 📋

### Basic syntax

```bash
docker [OPTIONS] COMMAND [ARG...]
```

**Practical examples**:
- `docker run -d -p 80:80 nginx`: Start a web server
- `docker ps -a`: List all containers
- `docker build -t myapp .`: Build an image

---

# Container management - Essentials 🚀

### Must-know commands

| Command | Description | Example |
|----------|-------------|---------|
| `docker run` | Create and start | `docker run -d -p 80:80 --name web nginx` |
| `docker ps` | Active containers | `docker ps` |
| `docker ps -a` | All containers | `docker ps -a` |
| `docker stop` | Stop | `docker stop web` |
| `docker start` | Restart | `docker start web` |
| `docker rm` | Remove | `docker rm web` |

---

# Most useful run options 🔧

### Essential parameters for docker run

```bash
# Detached with name and port
docker run -d --name my-app -p 8080:80 nginx

# Environment variables
docker run -e NODE_ENV=production -e PORT=3000 node-app

# Volumes and working directory
docker run -v $(pwd):/app -w /app node:18 npm install

# Resource limits
docker run --memory=512m --cpus=1 my-app
```

---

# Image management 📦

### Images: pull, build, manage

| Command | Description | Example |
|----------|-------------|---------|
| `docker pull` | Download | `docker pull nginx:alpine` |
| `docker build` | Build | `docker build -t myapp:v1.0 .` |
| `docker images` | List | `docker images` |
| `docker tag` | Tag | `docker tag myapp:v1.0 myapp:latest` |
| `docker rmi` | Remove | `docker rmi myapp:v1.0` |

---

# Inspection and debugging 🔍

### Understand what is happening

| Command | Usage | Example |
|----------|--------|---------|
| `docker logs` | View logs | `docker logs -f --tail 100 my-app` |
| `docker exec` | Run inside container | `docker exec -it my-app bash` |
| `docker inspect` | Full details | `docker inspect my-app` |
| `docker stats` | Resource usage | `docker stats` |

---

# Practical inspection commands 🎯

### Quick debugging

```bash
# Interactive shell access
docker exec -it my-container bash

# Example: run a command directly in the container to retrieve output on the host machine:
docker exec le_nom_du_container /usr/bin/mysqldump -u votre_utilisateur --password=votre_mot_de_passe le_nom_de_la_base_de_donnees > la_base_de_donnees.sql

# Real-time logs
docker logs -f my-container

# Resource monitoring
docker stats --no-stream

# Processes in the container
docker top my-container
```

---

# Volumes and networks 🌐

### Resource management

**Volumes**:
```bash
docker volume create my-volume
docker volume ls
docker volume inspect my-volume
docker volume rm my-volume
```

**Networks**:
```bash
docker network create my-network
docker network ls
docker network connect my-network my-container
```

---

# Cleanup and maintenance 🧹

### Free up disk space

| Command | Action | Impact |
|----------|--------|--------|
| `docker system prune` | General cleanup | Stopped containers, networks, dangling images |
| `docker container prune` | Stopped containers | Frees container space |
| `docker image prune` | Unused images | Cleans orphan images |
| `docker volume prune` | Unused volumes | Removes unnecessary volumes |

---

# Advanced cleanup 🗑️

### Monitoring and cleanup

```bash
# View disk usage
docker system df

# Full cleanup (CAUTION!)
docker system prune -a --volumes

# Force removal
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -q)
```
---

# Optimal daily workflow 🔄

### Typical development sequence

```bash
# 1. Build the image
docker build -t my-app:dev .

# 2. Launch in development mode
docker run -d -p 3000:3000 -v $(pwd):/app --name dev-app my-app:dev

# 3. Monitoring
docker logs -f dev-app

# 4. Debug if needed
docker exec -it dev-app bash

# 5. Cleanup
docker stop dev-app && docker rm dev-app
```

---

# Advanced commands for pros 🚀

### Advanced techniques

```bash
# Copy files container ↔ host
# concretely this means you can copy a file from your machine to the container
docker cp my-file.txt my-container:/app/my-file.txt
# and vice versa
docker cp my-container:/app/my-file.txt ./my-file.txt

# useful if you want to modify a file or retrieve a folder from the container

# Create image from container
docker commit my-container my-image:v2

# Image export/import
docker save -o my-app.tar my-app:latest
docker load -i my-app.tar
```

---

# CLI best practices 📋

### Tips for efficiency

✅ **Use explicit names**: `--name web-frontend`  
✅ **Always specify tags**: `nginx:1.25-alpine`  
✅ **Clean up regularly**: `docker system prune`  
✅ **Use aliases** for frequent commands  
✅ **Logs with limits**: `docker logs --tail 50`  

❌ Avoid `latest` in production  
❌ Don't forget to remove test containers
