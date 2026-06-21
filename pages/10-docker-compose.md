---
layout: new-section
routeAlias: 'docker-compose-orchestration'
---

<a name="DOCKER_COMPOSE" id="DOCKER_COMPOSE"></a>

# Docker Compose - Multi-Container Orchestration

---

### Orchestrate your multi-container applications

**Docker Compose** lets you define and manage multi-container applications with a single configuration file. No more endless `docker run` commands!

---

# Why Docker Compose? 🤔

### Problem without Compose

```bash
# Start a web stack manually
docker network create app-network
docker run -d --name database --network app-network postgres:15
docker run -d --name redis-cache --network app-network redis:alpine
docker run -d --name web-app --network app-network -p 3000:3000 my-app
docker run -d --name nginx-proxy --network app-network -p 80:80 nginx
```

---

# Problem without Compose (continued) 🚨

**🚨 Problems**: Complex, repetitive, hard to maintain!

---

# Solution with Compose ✨

### One file = your entire infrastructure

```yaml
# docker-compose.yml
version: '3.8'
services:
  database:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD: secret
  
  redis:
    image: redis:alpine
  
  web:
    build: .
    ports:
      - '3000:3000'
    depends_on:
      - database
      - redis
```

---

# Solution with Compose (result) 🚀

**One command**: `docker compose up` 🚀

---

# Modern 2026 Syntax ⚡

### New syntax (recommended)

```bash
# ✅ Modern Docker 2026 syntax
docker compose up -d
docker compose down
docker compose logs -f
docker compose restart web
```

---

# Modern 2026 Syntax (continued) ❌

### Old syntax (deprecated)

```bash
# ❌ Old syntax (avoid)
docker-compose up -d
docker-compose down
```

---

# Modern 2026 Syntax (conclusion) 📝

**Docker now integrates Compose natively!**

---

### Anatomy of a Compose file

```yaml
version: '3.8'

services: # Container definitions
  web:
    build: .
    ports:
      - '3000:3000'
networks: # Custom networks
  app-network:
    driver: bridge

volumes: # Shared volumes
  db-data:
    driver: local
secrets: # Secret management
  db-password:
    file: ./secrets/db_password.txt
```

---

# Essential Commands 🎯

### Full lifecycle

| Command | Description | Example |
|----------|-------------|---------|
| `docker compose up` | Start services | `docker compose up -d` |
| `docker compose down` | Stop and remove | `docker compose down` |
| `docker compose ps` | Service status | `docker compose ps` |

---

# Essential Commands (continued) 🎯

| Command | Description | Example |
|----------|-------------|---------|
| `docker compose logs` | View logs | `docker compose logs -f web` |
| `docker compose exec` | Run in a service | `docker compose exec web bash` |
| `docker compose restart` | Restart | `docker compose restart web` |

---

<div class="-mt-6">

##### Example docker-compose.yml file

```yaml
services:
  # PostgreSQL database
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: webapp
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U app']
      interval: 30s
      timeout: 10s
      retries: 3

  # Next.js application
  web:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://app:secret123@db:5432/webapp
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  # Nginx reverse proxy
  nginx:
    image: nginx:alpine
    ports:
      - '80:80'
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web
    restart: unless-stopped

volumes:
  postgres_data:

networks:
  default:
    name: webapp-network
```

</div>

---

**Dockerfile** for our Next.js app:

```dockerfile
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json package-lock.json ./
RUN npm ci; 
# npm install

# Rebuild source code only when needed
# 2nd stage, separates app build from runner
FROM base AS builder
# based on base, create a builder stage
WORKDIR /app
# copy app dependencies
COPY --from=deps /app/node_modules ./node_modules
# copy app source code
COPY . .

RUN npm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

# create user and group
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
# copy app public files
COPY --from=builder /app/public ./public
# copy app build files
# Copy Next.js build files
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# switch user
USER nextjs

# expose port 3000
EXPOSE 3000

# set port and hostname
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
```

---

## **nginx.conf** for the reverse proxy:

```nginx
events {
    worker_connections 1024;
}
#
# define upstream
http {
    upstream nextjs {
        server web:3000;
    }

    # define server
    server {
        listen 80;
        server_name localhost;

        # define location
        location / {
            # define proxy
            proxy_pass http://nextjs;
            proxy_http_version 1.1;
            # define headers
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            # define host
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
```

---

# Create the Next.js application 🚀

**Commands to create and prepare the app**:

```bash
# Create the Next.js application with TypeScript
npx create-next-app@latest my-app-nextjs --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"

# Go to the folder
cd my-app-nextjs

# Add standalone configuration
echo 'module.exports = {
  output: "standalone",
  experimental: {
    outputFileTracingRoot: require("path").join(__dirname, "../../"),
  },
}' > next.config.js

# Add PostgreSQL dependency
npm install pg @types/pg
```

---

# Concrete Case: Compose Magic ✨

**One command**:

```bash
docker compose up --build
```

**Compose does everything automatically**:
1. 🏗️ **Builds** the Next.js image from the Dockerfile
2. 🚀 **Starts** PostgreSQL with healthcheck
3. 🔗 **Connects** the app to the database via the network
4. 🌐 **Configures** Nginx as reverse proxy
5. ⚡ **Starts** the full stack on port 80

**Result**: Complete Next.js + PostgreSQL + Nginx stack working!

---

# Environment variables 🔧

<small>

### `.env` file for configuration

</small>

```bash
# .env
NODE_ENV=development
POSTGRES_DB=webapp
POSTGRES_USER=app
POSTGRES_PASSWORD=secret123
WEB_PORT=80
```

<small>

**Usage in docker-compose.yml**:

</small>

```yaml
services:
  web:
    environment:
      NODE_ENV: ${NODE_ENV}
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
  
  nginx:
    ports:
      - '${WEB_PORT}:80'
```

<div class="-mt-2">

**Compose automatically loads the `.env` file!**

</div>


---

# Profiles and environments 🎭

### Multi-environment management

```yaml
services:
  web:
    image: my-app:latest

  # Development-only service
  dev-tools:
    image: adminer
    ports:
      - '8080:8080'
    profiles:
      - dev

  # Production monitoring service
  monitoring:
    image: grafana/grafana
    profiles:
      - prod
```

---

**Commands**:

```bash
# Development
docker compose --profile dev up

# Production
docker compose --profile prod up
```

---

# Scaling and Load Balancing ⚖️

### Easy scaling

```bash
# Start 3 instances of the web service
docker compose up --scale web=3

# With a load balancer
docker compose up --scale web=3 --scale worker=5
```

**Nginx configuration for load balancing**:

```nginx
upstream nextjs {
    server web_1:3000;
    server web_2:3000;
    server web_3:3000;
}
```

---

# 2026 Best Practices ✅

### Modern recommendations

**🔒 Security**:

```yaml
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db-password
    secrets:
      - db-password
```

---

**📊 Monitoring**:

```yaml
services:
  web:
    healthcheck:
      test: [CMD, curl, -f, http://localhost:3000/health]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

---

# Debugging and Troubleshooting 🔍

### Useful commands for debugging

```bash
# View running services
docker compose ps

# Real-time logs
docker compose logs -f

# Inspect a specific service
docker compose logs web
```

**More commands**:

```bash
# Rebuild images
docker compose build --no-cache

# Validate configuration
docker compose config

# Full cleanup
docker compose down -v --remove-orphans
```

---

# CI/CD Integration 🚀

**Production with external secrets**:

```yaml
services:
  web:
    image: registry.company.com/my-app:${VERSION}
    environment:
      DATABASE_URL: ${DATABASE_URL}
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

**CI/CD deployment**:

```bash
# CI/CD deployment
export VERSION=v1.2.3
docker compose -f docker-compose.prod.yml up -d
```

---

# Summary 📚

### What you master now

✅ **Multi-container orchestration** with a single file

✅ **Modern syntax** Docker Compose 2026

✅ **Environment management** with profiles and .env

✅ **Custom image builds** with Next.js Dockerfile

✅ **Scaling** and load balancing

✅ **Best practices** for security and monitoring

✅ **Debugging** and troubleshooting

### 🚀 **Ready for the hands-on exercise!**

You can now create complete multi-container applications!
