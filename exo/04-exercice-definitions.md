---
layout: new-section
routeAlias: 'premier-contact-docker'
---

<a name="PREMIER_CONTACT" id="PREMIER_CONTACT"></a>

# Your first Docker exercise 🎯

---

## 🎯 Main Detailed Exercise

### Your first hands-on experience

Now that you know the concepts **AND** the CLI commands, let's get our hands dirty! This exercise lets you practice what you just learned.

---

# Check your installation 🔍

### Step 1: Verify that Docker is working

```bash
# Check your Docker version
docker --version

# Display basic information
docker info | head -10
```

### Simple questions:
- What version of Docker do you have?
- Is Docker running properly?

---

# First container: Hello World! 👋

### Step 2: Your very first container

```bash
# Run the official test container
docker run hello-world
```

### What just happened:
1. Docker **downloaded** the `hello-world` image
2. It **created** a container from that image
3. The container **displayed** a welcome message
4. The container **stopped** automatically

---

# Explore what exists 📦

### Step 3: Look at what you have now

```bash
# List downloaded images
docker images

# List all containers (including stopped ones)
docker ps -a
```

### Observation questions:
- How many images do you have now?
- What is the state of your `hello-world` container?

---

# Second container: A web server! 🌐

### Step 4: Run something useful

```bash
# Run an Nginx web server (in the background with a name)
docker run -d --name my-first-site nginx:alpine

# Verify it is running
docker ps
```

### Learning points:
- **`-d`** : Runs in the background (detached)
- **`--name`** : Gives the container a name
- **`nginx:alpine`** : Lightweight version of Nginx

---

# Interact with your container 💬

### Step 5: See what's happening

```bash
# View server logs
docker logs my-first-site

# View processes running inside the container
docker top my-first-site

# View resource usage
docker stats my-first-site --no-stream
```

---

# Clean up after yourself 🧹

### Step 6: Stop and remove

```bash
# Stop the web server
docker stop my-first-site

# Remove the container
docker rm my-first-site

# Verify it is gone
docker ps -a
```

---

## 🟡 Express Exercise 3: Explore inside a container (20 min)

**What you learn** : Interactive mode, differences between distributions

```bash
# 1. Enter an Ubuntu container
docker run -it ubuntu:latest bash

# Inside the container, explore:
ls /
cat /etc/os-release
ps aux
whoami

# Exit the container
exit

# 2. Compare with Alpine Linux
docker run -it alpine:latest sh

# Explore the differences:
ls /
cat /etc/os-release
ps aux

# Exit
exit

# View all images with their sizes (more readable)
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Bonus: view disk space used
docker system df
```

**Questions** :
- What are the main differences between Alpine and Ubuntu?

---

# Mastery test: Your turn! 🎯

### Step 7: Independent exercise

**Mission** : Run an Nginx container and PostgreSQL in the background with the name "my-nginx"

You can use the following command to verify if you succeeded:
```bash
docker ps
```

Try to curl the Nginx container from your machine — what happens?

---

```bash
# Your turn! Try without looking at the solution...
# Hint: nginx:alpine

# Solution (only look after trying):
docker run -d --name my-nginx nginx:alpine
docker run -d --name my-postgres postgres:alpine

# Verification
docker ps
docker logs my-nginx
docker logs my-postgres

# Cleanup
docker stop my-nginx && docker rm my-nginx
docker stop my-postgres && docker rm my-postgres

# if I want to stop all containers at once:
docker stop $(docker ps -q)
docker rm $(docker ps -a -q)

# if I want to stop all containers and images at once:
docker stop $(docker ps -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)

```

---

# Does your curl work?

```bash
curl http://localhost:80
```

No, because the Nginx container was not mapped to a port on your PC — we will cover this very soon in the next module.

---

### Discovery Exercise - Exploring popular images

**Mission** : Test different popular Docker images

```bash
# Try these images one by one
docker run --rm alpine:latest echo "I am Alpine Linux!"
docker run --rm ubuntu:latest cat /etc/os-release
docker run --rm python:3.12-alpine python --version
```

**Questions** :
- What does the `--rm` option do?

---

# 🎉 Congratulations!

### You have mastered:

✅ **Checking** your Docker installation
✅ **Running** your first container (`docker run`)
✅ **Listing** containers and images (`docker ps`, `docker images`)
✅ **Monitoring** your containers (`docker logs`, `docker stats`)
✅ **Managing the lifecycle** (`docker stop`, `docker rm`)
✅ **Practicing** independently

### 🚀 **Ready for the CLI!**

You now master the basic commands.

We can move on to advanced CLI commands!
