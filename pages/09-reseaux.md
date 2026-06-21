---
layout: new-section
routeAlias: 'reseaux-volumes-docker'
---

<a name="reseaux-volumes-docker" id="reseaux-volumes-docker"></a>

# Docker Networks & Volumes 🌐💾

---

## Why do we need networks and volumes? 🤔

### Problems to solve

**Without Docker networks**:
- Your containers cannot easily talk to each other
- Hard to make a web app communicate with its database

**Without Docker volumes**:
- 💀 **Your data disappears** when you remove a container
- Cannot share files between containers
- No persistence for your databases

### What Docker solves

✅ **Networks**: Simple communication between containers  
✅ **Volumes**: Your data survives containers  

---

## 💾 Volumes - The basic problem

### What happens WITHOUT volumes?

```bash
# Create a container with data
docker run -it --name test-data ubuntu:20.04 bash

# Inside the container, create an important file
echo "My important data" > /app/data.txt
exit

# PROBLEM: Removing the container = DATA LOSS
docker rm test-data

# 💀 The data.txt file is GONE forever!
```

**😱 Result**: All your data is **lost**!

---

## 🔧 Solution: Docker Volumes

### What exactly is a volume?

A **volume** is a **special folder** that Docker manages for you:

- 📁 **Stored on your hard drive** (not in the container)
- 🔄 **Shareable** between multiple containers
- 💾 **Persistent**: survives container removal
- 🛡️ **Managed by Docker**: backup, automatic permissions

**Analogy**: It's like an **external hard drive** you plug into different computers!

> You can also think of it as a virtual hard drive managed by Docker.

---

## 📊 Volume types - Understanding the differences

### 3 ways to manage your data

| Type | When to use | Where data lives |
|------|------------------|-------------------|
| **🤖 Anonymous volume** | By accident/beginner | Managed by Docker |
| **📛 Named volume** | **Production** | Managed by Docker |
| **📁 Bind mount** | **Development** | On your PC |

---

⚙️ Simple analogy: Volumes = USB keys

| Type | When to use | Where data lives | Analogy 🧠 |
|------|------------------|-------------------|-------------|
| **🤖 Anonymous volume** | Beginner / oversight | Docker (auto name) | 🕳️ USB key without a label thrown in a drawer — you never find it again |
| **📛 Named volume** | Production | Docker (chosen name) | 🏷️ USB key with your name, stored in a box — easy to find and reuse |
| **📁 Bind mount** | Development | On your PC | 💻 You work directly on a folder on your PC, as if your app were "live" |

---

## 🤖 Anonymous Volumes - What happens to beginners

### When Docker creates volumes automatically

```bash
# ❌ Beginner command (WITHOUT -v)
docker run -d --name mysql-test mysql:8.0

# 🤖 Docker automatically creates an ANONYMOUS volume
docker volume ls
# DRIVER    VOLUME NAME
# local     a1b2c3d4e5f6...  ← Volume with random name!
```

**⚠️ Problem**: Volume with a weird name, hard to find!

---

### Why does Docker do this automatically?

```bash
# View MySQL container details
docker inspect mysql-test

# In the details, you will see:
# "Mounts": [
#   {
#     "Type": "volume",
#     "Name": "a1b2c3d4e5f6...",
#     "Source": "/var/lib/docker/volumes/a1b2c3d4e5f6.../",
#     "Destination": "/var/lib/mysql"
#   }
# ]
```

**💡 Why?** MySQL **needs** to persist its data, so Docker automatically creates a volume for `/var/lib/mysql`!

---

## 📛 Named Volumes - Best practice

### Create and use a volume with an explicit name

```bash
# ✅ Create a volume with a clear name
docker volume create mysql-data

# ✅ Use this volume with your container
docker run -d \
  --name mysql-prod \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=password123 \
  mysql:8.0

# ✅ Verify your data is there
docker volume ls
# DRIVER    VOLUME NAME
# local     mysql-data    ← Clear, readable name!
```

---

### Data persistence test

```bash
# 1. Create a database
docker exec -it mysql-prod mysql -p
# allows running two commands at once: connect to the container and execute a command
# CREATE DATABASE test_app;
# exit

# 2. REMOVE the container (crash simulation)
docker stop mysql-prod
docker rm mysql-prod

# 3. Recreate a new container with the SAME volume
docker run -d \
  --name mysql-nouveau \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=password123 \
  mysql:8.0

# 4. Verify data is STILL THERE!
docker exec -it mysql-nouveau mysql -p
# SHOW DATABASES;  ← test_app is still there! ✅
```

**🎉 Result**: Your data **survived** container destruction!

---

## 📁 Bind Mounts - For development

### Link a folder on your PC to the container

```bash
# Create a folder on your PC
mkdir ~/my-project
echo "console.log('Hello Docker!');" > ~/my-project/app.js

# Link this folder to the container
docker run -it \
  --name dev-container \
  -v ~/my-project:/app \
  node:18-alpine \
  sh

# Inside the container:
# cd /app
# ls -la        ← You see app.js!
# node app.js   ← "Hello Docker!"
```

---

### Bind mount magic - Real-time modification

```bash
# On your PC, modify the file
echo "console.log('Modified from my PC!');" > ~/my-project/app.js

# Inside the container, run again
# node app.js   ← "Modified from my PC!"
```

**🪄 Magic**: Changes on your PC appear **instantly** in the container!

---

### What REALLY happens with a bind mount:

- Your PC folder is **mounted directly** in the container
- There is **no file copy**: it's the same file seen from both sides
- The container reads/writes directly in the host folder
- Any change on the PC is **instantly visible** in the container
- And vice versa, what the container does modifies the file on the host
- You can verify with `cat /app/app.js` or `cat ~/my-project/app.js` → same content

🧠 Note: If a folder already exists in the container (e.g. /app), the bind mount will **hide** its content. Your PC folder **completely replaces** the container one. The container's initial content at that location is **invisible**, but **not deleted**

If you remove the bind mount, the container folder regains its initial content.

---

## 🌐 Docker Networks - The communication problem

### Why don't containers talk to each other by default?

```bash
# Start 2 separate containers
docker run -d --name app1 nginx:alpine
docker run -d --name app2 nginx:alpine

# Try to make app1 communicate with app2
docker exec app1 ping app2
# ping: bad address 'app2'  ← FAILURE!
```

**😕 Problem**: Containers are **isolated** by default!

---

## 🔗 Solution: Create a custom network

### Containers can talk to each other by name

```bash
# 1. Create a custom network
docker network create my-network

# 2. Start containers on this network
docker run -d --name app1 --network my-network nginx:alpine
docker run -d --name app2 --network my-network nginx:alpine

# 3. Now they can talk!
docker exec app1 ping app2
# PING app2 (172.20.0.3): 56 data bytes  ← ✅ IT WORKS!

# They are both on the same "my-network" network and can talk to each other.
```

**🎯 Result**: Communication by **container name**!

---

## 🏗️ Concrete example: Website + Database

### Complete stack that works together

```bash
# 1. Create infrastructure
docker network create webapp-network
docker volume create database-data

# 2. Start the database
docker run -d \
  --name database \
  --network webapp-network \
  -v database-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=myapp \
  mysql:8.0
```

---

### Continued: Web application

```bash
# 3. Start the web application
docker run -d \
  --name webapp \
  --network webapp-network \
  -p 3000:3000 \
  -e DATABASE_HOST=database \
  -e DATABASE_USER=root \
  -e DATABASE_PASSWORD=secret \
  -e DATABASE_NAME=myapp \
  node:18-alpine \
  sh -c "
    npm init -y &&
    npm install express mysql2 &&
    echo 'const express = require(\"express\");
    const app = express();
    app.get(\"/\", (req, res) => res.send(\"App connected to MySQL!\"));
    app.listen(3000);' > app.js &&
    node app.js
  "
```

---

### Full stack test

```bash
# 4. Test that everything works
curl http://localhost:3000
# "App connected to MySQL!"  ← ✅ IT WORKS!

# 5. See communicating containers
docker exec webapp ping database
# PING database (172.21.0.2)  ← Network communication ✅

# 6. Verify persistence
docker volume inspect database-data
# MySQL data is saved ✅
```

---

## 🔍 Docker network types - The real differences

### 🤔 Why do bridge and host seem similar?

At first glance, **bridge** and **host** look the same:
- ✅ Containers can access the Internet
- ✅ You can expose ports
- ✅ It works for your apps

**BUT** the difference is in **network isolation** and **how it works under the hood**!

---

### 🧱 Bridge network (default) - Secure isolation

```bash
# The container has its own virtual network
docker run -d -p 8080:80 --name web nginx

# ✅ What happens:
# - Container has an internal IP (e.g. 172.17.0.2)
# - You MUST use -p to expose ports
# - Accessible via localhost:8080 on your PC
# - Container isolated from your PC's network
```

**🔒 Isolation**: Container in its network bubble, more secure

---

### 🏠 Host network - Maximum performance

```bash
# The container uses your machine's network directly
docker run -d --network host --name web nginx

# ⚡ What happens:
# - Container uses your PC's IP
# - NO need for -p → nginx accessible directly on port 80
# - Faster because no virtual network layer
# - ⚠️ Works ONLY on native Linux (not Docker Desktop Mac/Windows)
```

**🚀 Performance**: Container "merged" with your PC, faster

---

### 🚫 None network - Total isolation

```bash
# No network at all
docker run -d --network none --name isolated alpine

# 🔒 What happens:
# - No Internet access
# - No communication with other containers
# - Perfect for sensitive data processing
```

**🔐 Security**: Container completely cut off from the world

---

### 📊 Comparison table - Bridge vs Host vs None

| Mode | Container IP? | Isolation? | Port access | Performance | Typical use |
|------|---------------|-------------|-----------------|-------------|---------------|
| **🧱 bridge** | ✅ Yes (virtual) | ✅ Secure | via `-p` | Standard | Normal apps, production |
| **🏠 host** | ❌ No (host IP) | ❌ None | direct | Maximum | High-perf apps, debug |
| **🚫 none** | ❌ None | ✅ Total | none | N/A | Isolated processing |
| **🔗 custom bridge** | ✅ Yes | ✅ Secure | via `-p` + DNS | Standard | Multi-containers |

---

### 🎯 Concrete examples of differences

```bash
# === BRIDGE (default) ===
docker run -d -p 8080:80 --name web-bridge nginx
# → Accessible at http://localhost:8080
# → Container IP: 172.17.0.2 (virtual network)

# === HOST ===
docker run -d --network host --name web-host nginx
# → Accessible at http://localhost:80 (direct)
# → Container IP: same as your PC

# === Comparison ===
docker exec web-bridge ip addr    # Virtual Docker IP
docker exec web-host ip addr      # Your PC's IP
```

---

### ⚠️ Important limitations

**Host network**:
- ❌ **Works ONLY on native Linux**
- ❌ Docker Desktop (Mac/Windows) → host = bridge automatically
- ❌ Less secure (no isolation)
- ❌ Possible port conflicts with the host

**Bridge network**:
- ⚠️ Containers on default bridge cannot see each other by name
- ✅ Solution: create a custom bridge

---

### 💡 Analogies to remember

**🧱 Bridge**:
- **Analogy**: You're in a shared flat with other roommates (containers): you can talk to each other (same network), and you all have Internet access.

**🏠 Host**:
- **Analogy**: You work **alone** on your own PC connected directly to the Internet — no partitions, you do everything yourself, fast, but less secure.

**🚫 None**:
- **Analogy**: You work in a **room with no Wi-Fi, no cable, nothing**: impossible to communicate, even with your neighbors.

---

## 📋 Essential commands - Diagnostics and debug

### Networks - See what is happening

```bash
# List all networks
docker network ls

# View network details (which containers are on it)
docker network inspect my-network

# Connect an existing container to a network
docker network connect my-network my-container

# Test connectivity between containers
docker exec container1 ping container2
docker exec container1 nslookup container2
```

---

### Volumes - Manage your data

```bash
# List all volumes
docker volume ls

# See where Docker stores a volume on your disk
docker volume inspect my-volume

# Clean unused volumes
docker volume prune

# View space used by Docker
docker system df

# Volume backup
docker run --rm -v my-volume:/data -v $(pwd):/backup alpine \
  tar czf /backup/backup.tar.gz -C /data .
```

---

## 🚨 Common errors and solutions

### "Container can't connect to database"

```bash
# ❌ Error: containers not on the same network
docker run -d --name db mysql:8.0
docker run -d --name app my-app  # Different networks!

# ✅ Solution: same network
docker network create app-net
docker run -d --name db --network app-net mysql:8.0
docker run -d --name app --network app-net my-app
```

---

### "Data lost after container restart"

```bash
# ❌ Error: no volume
docker run -d --name db mysql:8.0  # Data lost!

# ✅ Solution: named volume
docker volume create db-data
docker run -d --name db -v db-data:/var/lib/mysql mysql:8.0
```

---

### "Permission denied in bind mount"

```bash
# ❌ Error: permission problem
docker run -v /host/folder:/container/folder image

# ✅ Solution: use the :Z option for SELinux
docker run -v /host/folder:/container/folder:Z image

# ✅ Alternative: change permissions
chmod 755 /host/folder
```

---

## 🛡️ 2026 Best practices

### Secure networks

✅ **DO** - Create separate networks by function:
```bash
docker network create frontend-net
docker network create backend-net
# Web servers on frontend-net
# Databases on backend-net
```

❌ **DON'T** - Use the default bridge network in production

---

### Optimized volumes

✅ **DO** - Named volumes in production:
```bash
docker volume create app-data
docker run -v app-data:/data my-app
```

✅ **DO** - Bind mounts in development:
```bash
docker run -v $(pwd)/src:/app/src my-app
```

❌ **DON'T** - Anonymous volumes (except special cases)

---

### Security

✅ **DO** - Read-only when possible:
```bash
docker run -v /host/config:/app/config:ro my-app
```

✅ **DO** - Internal networks for databases:
```bash
docker network create --internal db-network
```

❌ **DON'T** - Expose database ports directly

---

## 🎯 Summary - What you learned

### Volumes 💾
- **Problem**: Data disappears with containers
- **Solution**: Volumes for persistence
- **Types**: Anonymous (avoid), named (production), bind mounts (dev)

### Networks 🌐
- **Problem**: Containers isolated by default
- **Solution**: Custom networks for communication
- **Magic**: Communication by container name
- **Types**: Bridge (secure), Host (performance), None (isolated)

### Next step 🚀
Ready for **Docker Compose** which simplifies all of this!
