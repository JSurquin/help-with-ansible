---
layout: new-section
routeAlias: 'exercices-dockerfile'
---

<a name="exercices-dockerfile" id="exercices-dockerfile"></a>

# Dockerfile Exercises 📝

### 3 simple progressive levels

Learn Docker step by step!

---

## 🎮 Express Exercises (Warm-up)

### 3 quick exercises to create your first images

Before the main exercises, simple Dockerfiles to warm up!

---

### 🟢 Express Exercise 1: Custom Nginx Page - Customize an nginx page (20 min)

```bash
# 1. Create a custom page
mkdir my-nginx && cd my-nginx
```

```html
# 2. Create the HTML file: index.html
<!DOCTYPE html>
<html>
<head><title>My Custom Docker</title></head>
<body style="font-family: Arial; text-align: center; padding: 50px; background: #e3f2fd;">
    <h1>🐳 My First Custom Image</h1>
    <p>I created this page with Dockerfile!</p>
    <p>Version: <strong>1.0</strong></p>
</body>
</html>
```

```dockerfile
# 2. Create the Dockerfile
FROM nginx:alpine
LABEL author="me"
COPY index.html /usr/share/nginx/html/
```

---

```bash
# 3. Build and test
docker build -t my-nginx:v1 .
docker run -d --name test-nginx -p 8080:80 my-nginx:v1
echo "🌐 Test: http://localhost:8080"

# 4. Cleanup
docker stop test-nginx && docker rm test-nginx
```

---

### 🟡 Express Exercise 2: Simple Node.js App - Containerize a basic web app (25 min)

```bash
# 1. Create the Node.js app
mkdir my-app && cd my-app
```

```json
# 2. Create the package.json file
{
  "name": "docker-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

---

```javascript
# 3. Create the server.js file
const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
    res.send(`
        <h1>🚀 Dockerized Node.js App</h1>
        <p>Express server in a container</p>
        <p>Port: ${PORT}</p>
    `);
});

app.listen(PORT, () => {
    console.log(`Server on port ${PORT}`);
});
```

---

```dockerfile
# 2. Dockerfile for Node.js
FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
```

```bash
# 3. Build and test
docker build -t my-app:v1 .
docker run -d --name test-app -p 3000:3000 my-app:v1
echo "🌐 App: http://localhost:3000"

# 4. Cleanup
docker stop test-app && docker rm test-app
```

---

### 🔴 Express Exercise 3: Optimized Multi-stage - Optimize with a 2-step build (30 min)

```bash
# 1. Prepare the project
mkdir optimized-app && cd optimized-app
```

---

# Simple app that generates static content

```javascript
const fs = require('fs');

const html = `
<!DOCTYPE html>
<html>
<head><title>Optimized App</title></head>
<body style="font-family: Arial; text-align: center; padding: 50px; background: #f3e5f5;">
    <h1>⚡ Multi-Stage Image</h1>
    <p>This image has been optimized!</p>
    <p>Generated at: ${new Date().toLocaleString()}</p>
</body>
</html>
`;

fs.writeFileSync('dist/index.html', html);
console.log('✅ Content generated');

{
  "name": "builder-app",
  "scripts": {
    "build": "mkdir -p dist && node build.js"
  }
}
```
---

```dockerfile
# 2. Multi-stage Dockerfile
# Step 1: Builder
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json build.js ./
RUN npm run build

# Step 2: Lightweight production
FROM nginx:alpine AS production
LABEL stage="production"
COPY --from=builder /app/dist/ /usr/share/nginx/html/
```

---

```dockerfile
# 3. Comparison with simple version
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm run build
COPY dist/ /usr/share/nginx/html/
```

---

```bash
# 4. Build both versions
docker build -t optimized:multistage .
docker build -f Dockerfile.simple -t optimized:simple .

# 5. Compare sizes
echo "📊 Size comparison:"
docker images | grep optimized

# 6. Test
docker run -d --name test-opt -p 8080:80 optimized:multistage
echo "🌐 Optimized app: http://localhost:8080"

# 7. Cleanup
docker stop test-opt && docker rm test-opt
```

---

## 🎯 Main Detailed Exercises

---

### 🟢 Simple Level Exercise - Customize a web page

**Objective** : Customize an nginx image with your own page

**What you learn** :
- `FROM` : Choose a base image
- `COPY` : Add your files
- `ENV` : Environment variables

**Instructions** :
1. Start from `nginx:alpine`
2. Add your custom web page
3. Test the result

---

### 🟢 Simple Level Solution

```bash
# 1. Create the project
mkdir my-site
cd my-site
```

```html
# 2. Create a simple web page
# 2. Create the HTML file: index.html
<!DOCTYPE html>
<html>
<head>
    <title>My Docker Site</title>
    <style>
        body {
            font-family: Arial;
            text-align: center;
            padding: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .card {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            max-width: 500px;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>🐳 My First Dockerfile</h1>
        <p>I created my first custom image!</p>
        <p><strong>Environment:</strong> <span id="env">Production</span></p>
        <hr style="border: 1px solid rgba(255,255,255,0.3);">
        <small>Powered by Docker 🚀</small>
    </div>
</body>
</html>
```

---

### 🟢 Simple Dockerfile

```dockerfile
# 3. Create the Dockerfile
# Base image
FROM nginx:alpine

# Image information
LABEL maintainer="me@training.fr"
LABEL description="My first custom site"

# Environment variables
ENV SITE_NAME="My Docker Site"
ENV VERSION="1.0"

# Copy my web page into nginx
COPY index.html /usr/share/nginx/html/

# Port 80 is already exposed by nginx
```

```bash
# 4. Build the image
docker build -t my-site:v1 .

# 5. Test
docker run -d --name test-site -p 8080:80 my-site:v1

echo "🌐 Your site: http://localhost:8080"

# 6. Verification
curl -I http://localhost:8080

# 7. Cleanup
docker stop test-site && docker rm test-site
```

**✅ Result** : Your first custom Docker image!

---

### 🟡 Intermediate Level Exercise - Add useful tools

**Objective** : Create an image with a few practical tools

**What you learn** :
- `RUN` : Install packages
- `WORKDIR` : Set the working directory
- `CMD` : Default command

**Tools added** :
- `curl` : To test URLs
- `nano` : Text editor
- `htop` : View processes

---

### 🟡 Intermediate Level Solution

```bash
# 1. Create the project
mkdir docker-tools
cd docker-tools
```

```bash
# 2. Simple help script
#!/bin/sh
echo "🛠️ Available tools:"
echo "  curl - Test URLs"
echo "  nano - Edit files"
echo "  htop - View processes"
echo ""
echo "Examples:"
echo "  curl https://httpbin.org/json"
echo "  nano test.txt"
echo "  htop"

chmod +x help.sh
```

---

### 🟡 Intermediate Dockerfile

```dockerfile
# 3. Dockerfile with tools
# Lightweight base image
FROM alpine:latest

# Info
LABEL description="Image with useful tools"
LABEL version="2.0"

# Install tools
RUN apk update && apk add --no-cache \
    curl \
    nano \
    htop \
    bash

# Copy the help script
COPY help.sh /usr/local/bin/help

# Make executable
RUN chmod +x /usr/local/bin/help

# Working directory
WORKDIR /workspace

# Welcome message
RUN echo 'echo "Type: help"' >> /etc/profile

# Default command
CMD ["sh", "-l"]
```

```bash
# 4. Build and test
docker build -t tools:v2 .

# 5. Interactive test
docker run -it --name test-tools tools:v2

# Inside the container:
# help
# curl https://httpbin.org/json
# exit

# 6. Cleanup
docker rm test-tools
```

**✅ Result** : Image with practical tools for testing and debugging

---

### 🔴 Advanced Level Exercise - Simple multi-stage

**Objective** : Optimize size with a 2-step build

**What you learn** :
- Multi-stage build
- `COPY --from=`
- Image optimization

**Concept** :
- Step 1 : Prepare files
- Step 2 : Lightweight final image

---

### 🔴 Multi-stage Solution

```bash
# 1. Create the project
mkdir site-optimized
cd site-optimized
```

```html
# 2. Create multiple pages
<!DOCTYPE html>
<html>
<head>
    <title>Optimized Site</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f0f8ff; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Multi-Stage Site</h1>
        <p>This image was optimized with a multi-stage build!</p>
        <a href="about.html">About</a>
    </div>
</body>
</html>
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>About</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f0f8ff; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>About</h1>
        <p>Site created with Docker multi-stage build</p>
        <a href="index.html">Back</a>
    </div>
</body>
</html>
```

---

### 🔴 Multi-stage Dockerfile

```dockerfile
# 3. Optimized Dockerfile
# ================================
# Step 1: Preparation
# ================================
FROM alpine:latest AS builder

# Install tools for preparation
RUN apk add --no-cache curl

# Copy source files
WORKDIR /src
COPY *.html ./

# Simulate optimization (minification)
RUN mkdir /dist && \
    cp *.html /dist/

# ================================
# Step 2: Final image
# ================================
FROM nginx:alpine AS production

# Metadata
LABEL stage="production"
LABEL optimized="true"

# Copy ONLY the final files
# nginx:alpine is already optimized
COPY --from=builder /dist/ /usr/share/nginx/html/
```

---

```dockerfile
# Non-optimized version for comparison
FROM nginx:alpine
RUN apk add --no-cache curl
COPY *.html /usr/share/nginx/html/
```

```bash
# 4. Build both versions to compare
docker build -t site-optimized:multistage .
docker build -f Dockerfile.simple -t site-optimized:simple .

# 5. Compare sizes
echo "📊 Size comparison:"
docker images | grep site-optimized

# 6. Test
docker run -d --name site-opt -p 8080:80 site-optimized:multistage
echo "🌐 Site: http://localhost:8080"

# 7. Cleanup
docker stop site-opt && docker rm site-opt
```

**✅ Result** : Smaller optimized image thanks to multi-stage!

---

### Dockerfile Summary 📋

#### What we learned simply

**🟢 Simple Level** :
- `FROM` : Choose a base image
- `COPY` : Add your files
- `ENV` : Environment variables
- `LABEL` : Metadata

**🟡 Intermediate Level** :
- `RUN` : Install packages
- `WORKDIR` : Working directory
- `CMD` : Default command
- Basic help scripts

---

### Dockerfile Summary (continued) 📋

**🔴 Advanced Level** :
- Multi-stage build (2 steps)
- `COPY --from=` : Copy from a stage
- Size optimization
- Image comparison

#### 🎯 **Logical progression mastered!**

**Next step** : Docker Compose to orchestrate multiple containers!
---

### 💡 Key points to remember

#### Essential Dockerfile instructions

```dockerfile
FROM image:tag          # Base image
LABEL key="value"       # Metadata
ENV VAR=value          # Environment variables
RUN command            # Execute during build
COPY source dest       # Copy files
WORKDIR /path          # Working directory
CMD ["command"]        # Default command
```

#### Simple best practices

1. **Lightweight base images** (`alpine`)
2. **Single responsibility** per image
3. **Multi-stage** for optimization
4. **Labels** for documentation

#### 🚀 **Docker mastered progressively!**
