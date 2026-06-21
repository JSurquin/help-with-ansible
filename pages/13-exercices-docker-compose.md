---
layout: new-section
routeAlias: 'exercices-docker-compose'
---

<a name="EXERCICES_COMPOSE" id="EXERCICES_COMPOSE"></a>

# Docker Compose Exercises 🎼

### 3 progressive DevOps levels

Orchestrate multiple containers easily!

---

## 🎮 Express Exercises (Warm-up)

### 3 quick exercises with official images

Before the main exercises, short exercises to master the basics!

---

## 🟢 Express Exercise 1: My First Stack

### Super simple stack with 2 services (15 min)

**Possible choices** :
- nginx + redis
- nginx + mysql
- nginx + postgres
- nginx + mongo
- nginx + elasticsearch
- nginx + kibana

**What you learn** : First docker-compose.yml, linked services

---

## 🟢 Express 1 - YAML Configuration

```yaml
# Create docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - '8080:80'
  cache:
    image: your_choice:alpine
```

---

## 🟢 Express 1 - Tests and verification

```bash
# Test the stack
docker compose up -d
docker compose ps
curl http://localhost:8080
docker compose down
```

**Mission** : See the "nginx welcome page" at http://localhost:8080

---

## 🟡 Express Exercise 2: Database Stack

### Postgres + Adminer to explore a database (20 min)

**What you learn** : Environment variables, volumes, web interface

---

## 🟡 Express 2 - Database Configuration

```yaml
# More sophisticated docker-compose.yml
version: '3.8'

services:
  database:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password123
    volumes:
      - db_data:/var/lib/postgresql/data
```

---

## 🟡 Express 2 - Adminer Interface

```yaml
# Continuation of docker-compose.yml
  adminer:
    image: adminer:latest
    ports:
      - '8081:8080'
    depends_on:
      - database

volumes:
  db_data:
```

---

## 🟡 Express 2 - Tests and access

```bash
# Full test
docker compose up -d
echo "🌐 Database interface: http://localhost:8081"
# Connect via Adminer with the credentials
docker compose down -v
```

**Mission** : Connect to the database via the Adminer web interface

---

## 🔴 Express Exercise 3: Simple Monitoring Stack

### Prometheus + Grafana for monitoring (25 min)

**What you learn** : Monitoring stack, custom networks

---

## 🔴 Express 3 - Prometheus Service

```yaml
# docker-compose.yml monitoring
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - '9090:9090'
    networks:
      - monitoring
```

---

## 🔴 Express 3 - Grafana Service

```yaml
# Continuation of docker-compose.yml
  grafana:
    image: grafana/grafana:latest
    ports:
      - '3000:3000'
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin123
    networks:
      - monitoring
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

---

## 🔴 Express 3 - Deployment and access

```bash
# Monitoring deployment
docker compose up -d
echo "📊 Prometheus: http://localhost:9090"
echo "📈 Grafana: http://localhost:3000 (admin/admin123)"
docker compose down -v
```

**Mission** : Access both monitoring interfaces

---

## 🎯 Main Detailed Exercises

---

# 🟢 Simple Level Exercise

### WordPress + MySQL (Blog stack)

**Objective** : Deploy a WordPress blog with a database

**Instructions** :
1. Use the official `wordpress:latest` image
2. Database `mysql:8.0`
3. Configure volumes for persistence
4. Accessible on port 8080

---

# 🟢 Simple Level Solution

```yaml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    ports:
      - '8080:80'
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress123
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress123
      MYSQL_ROOT_PASSWORD: rootpass123
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  wordpress_data:
  mysql_data:
```

---

# 🟢 Simple Test and Management

### Deployment and verification

```bash
# Start the stack
docker compose up -d

# Verify services
docker compose ps

# View logs
docker compose logs wordpress
docker compose logs db

# Test access
echo "🌐 WordPress: http://localhost:8080"
curl -I http://localhost:8080

# Stop cleanly
docker compose down
```

**✅ Result** : Functional WordPress blog with data persistence

---

# 🟡 Intermediate Level Exercise

### NGINX + Node.js + Redis Stack

**Objective** : Web application with proxy and cache

**Instructions** :
1. NGINX proxy on port 80
2. Node.js application (`node:18-alpine` image)
3. Redis cache for sessions
4. Separate frontend/backend networks

---

### 🟡 Intermediate Level Solution - Configuration with networks

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - '80:80'
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    networks:
      - frontend

  app:
    image: nginx:alpine
    expose:
      - '80'
    volumes:
      - ./html:/usr/share/nginx/html:ro
    networks:
      - frontend
      - backend
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    networks:
      - backend
    volumes:
      - redis_data:/data

volumes:
  redis_data:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
```

---


<div class="-mt-4">

### 🟡 Nginx - Basic configuration (nginx.conf)

```bash
# Create the NGINX configuration
mkdir -p nginx
```

```nginx
# 2. Create the nginx.conf file
events {
    worker_connections  1024;
}

http {
    upstream app {
        server app:80;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location /health {
            return 200 'healthy\n';
            add_header Content-Type text/plain;
        }
    }
}
```

</div>

---

## 🟡 Nginx - Sample web page

```bash
# Create a simple web page
mkdir -p html
```

```html
<!-- 2. Create the index.html file -->
<!DOCTYPE html>
<html>
<head>
    <title>NGINX + Redis Stack</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; background: #f0f8ff; }
        .card { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 Intermediate Stack</h1>
        <p>NGINX Proxy + Application + Redis Cache</p>
        <p>✅ Working proxy</p>
        <p>✅ Redis cache in the background</p>
        <p>✅ Separate networks</p>
    </div>
</body>
</html>
```

---

# 🟡 Intermediate Stack Test

```bash
# Deploy the full stack
docker compose up -d

# Verify all services
docker compose ps

# Test the proxy
curl http://localhost/
curl http://localhost/health

# Verify Redis
docker compose exec redis redis-cli ping

# Log monitoring
docker compose logs -f nginx

# Cleanup
docker compose down -v
```

**✅ Result** : 3-tier stack with proxy and cache

---

# 🔴 Advanced Level Exercise

### Monitoring Stack (Prometheus + Grafana)

**Objective** : Complete monitoring infrastructure

**Instructions** :
1. Prometheus monitoring server
2. Grafana visualization interface
3. Node Exporter for system metrics
4. AlertManager for email alerts

---

# 🔴 Advanced Level Solution

### Complete monitoring stack

---

## 🔴 Advanced - Prometheus Service

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - '9090:9090'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
      - --web.console.libraries=/etc/prometheus/console_libraries
      - --web.console.templates=/etc/prometheus/consoles
    networks:
      - monitoring
```

---

## 🔴 Advanced - Grafana Service

```yaml
# Continuation of docker-compose.yml
  grafana:
    image: grafana/grafana:latest
    ports:
      - '3000:3000'
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin123
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring
```

---

## 🔴 Advanced - Node Exporter

```yaml
# Continuation of docker-compose.yml
  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - '9100:9100'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - --path.procfs=/host/proc
      - --path.rootfs=/rootfs
      - --path.sysfs=/host/sys
      - --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)
    networks:
      - monitoring
```

---

## 🔴 Advanced - AlertManager and volumes

```yaml
# Continuation of docker-compose.yml
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - '9093:9093'
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

---

## 🔴 Config - Prometheus File

```yaml
# Prometheus configuration
# Create the prometheus.yml file
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
```

---

## 🔴 Config - AlertManager File

```yaml
# AlertManager configuration
# Create the alertmanager.yml file
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@example.org'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'
```

---

# 🔴 Deployment and Monitoring

```bash
# Deploy the monitoring stack
docker compose up -d

# Wait for everything to be ready
sleep 30

# Verify all services
docker compose ps

# Access URLs
echo "📊 Prometheus: http://localhost:9090"
echo "📈 Grafana: http://localhost:3000 (admin/admin123)"
echo "🔔 AlertManager: http://localhost:9093"
echo "📊 Node Exporter: http://localhost:9100"

# Automatic tests
curl -s http://localhost:9090/-/healthy && echo "✅ Prometheus OK"
curl -s http://localhost:3000/api/health && echo "✅ Grafana OK"
curl -s http://localhost:9100/metrics | head -5 && echo "✅ Node Exporter OK"

# Real-time monitoring
docker compose logs -f prometheus
```

**✅ Result** : Production-ready monitoring infrastructure

---

# 🔵 Expert Level Exercise

### Complete DevOps Stack (GitLab + Registry + Runner)

**Objective** : Complete CI/CD platform with GitLab

**Instructions** :
1. GitLab CE for source code
2. GitLab Registry for images
3. GitLab Runner for pipelines
4. PostgreSQL as the database

---

### 🔵 Expert Level Solution - Complete GitLab infrastructure

```yaml
version: '3.8'

services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    hostname: gitlab.local
    ports:
      - '80:80'
      - '443:443'
      - '2222:22'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.local'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
        postgresql['enable'] = false
        gitlab_rails['db_adapter'] = 'postgresql'
        gitlab_rails['db_encoding'] = 'utf8'
        gitlab_rails['db_host'] = 'postgresql'
        gitlab_rails['db_port'] = 5432
        gitlab_rails['db_database'] = 'gitlab'
        gitlab_rails['db_username'] = 'gitlab'
        gitlab_rails['db_password'] = 'gitlab123'
    volumes:
      - gitlab_config:/etc/gitlab
      - gitlab_logs:/var/log/gitlab
      - gitlab_data:/var/opt/gitlab
    depends_on:
      - postgresql
    networks:
      - gitlab-network

  postgresql:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: gitlab
      POSTGRES_USER: gitlab
      POSTGRES_PASSWORD: gitlab123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - gitlab-network

  gitlab-runner:
    image: gitlab/gitlab-runner:latest
    volumes:
      - gitlab_runner_config:/etc/gitlab-runner
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - gitlab-network
    depends_on:
      - gitlab

volumes:
  gitlab_config:
  gitlab_logs:
  gitlab_data:
  postgres_data:
  gitlab_runner_config:

networks:
  gitlab-network:
    driver: bridge
```

---

### 🔵 GitLab Deployment Script (deploy-gitlab.sh)

```bash
# GitLab deployment script
# Create the deploy-gitlab.sh file
#!/bin/bash

echo "🚀 Deploying GitLab DevOps Stack..."

# Add local hostname
echo "127.0.0.1 gitlab.local" | sudo tee -a /etc/hosts

# Start the stack
docker compose up -d

echo "⏳ GitLab starting... (may take 5-10 minutes)"
echo "📊 Startup monitoring:"
```

---

## 🔵 GitLab Wait Script

```bash
# Continuation of deploy-gitlab.sh script

# Wait for GitLab to be ready
until curl -s http://gitlab.local/users/sign_in > /dev/null; do
  echo "⏳ GitLab starting up..."
  sleep 30
done

echo "✅ GitLab is ready!"

# Retrieve initial root password
echo "🔑 Initial root password:"
docker compose exec gitlab cat /etc/gitlab/initial_root_password | grep Password:

echo ""
echo "🌐 GitLab: http://gitlab.local"
echo "👤 User: root"
echo "🔧 Runner configuration: docker compose exec gitlab-runner gitlab-runner register"

chmod +x deploy-gitlab.sh
```

---

# 🔵 GitLab Runner Configuration

### Automatic Runner registration

---

## 🔵 Runner configuration script

```bash
# Runner configuration script
# Create the setup-runner.sh file
#!/bin/bash

echo "🏃 Configuring GitLab Runner..."

# Retrieve registration token
echo "1. Go to http://gitlab.local/admin/runners"
echo "2. Copy the registration token"
echo "3. Run the following command:"
```

---

## 🔵 Runner registration command

```bash
# Continuation of setup-runner.sh script

echo ""
echo "docker compose exec gitlab-runner gitlab-runner register \\"
echo "  --non-interactive \\"
echo "  --url http://gitlab.local \\"
echo "  --registration-token YOUR_TOKEN \\"
echo "  --executor docker \\"
echo "  --docker-image alpine:latest \\"
echo "  --description 'Docker Runner' \\"
echo "  --tag-list 'docker,linux' \\"
echo "  --docker-privileged"

echo ""
echo "✅ Runner configured to run Docker pipelines"

chmod +x setup-runner.sh
```

---

# 🔵 Complete DevOps Stack Test

---

## 🔵 Deployment and wait

```bash
# Full deployment
./deploy-gitlab.sh

# Wait for full startup
sleep 300
```

---

## 🔵 Tests and verifications

```bash
# Verifications
echo "🧪 Testing the DevOps stack..."

# Test GitLab
curl -I http://gitlab.local && echo "✅ GitLab accessible"

# Verify PostgreSQL
docker compose exec postgresql pg_isready -U gitlab && echo "✅ PostgreSQL OK"

# Service status
docker compose ps
```

---

## 🔵 Final information

```bash
echo ""
echo "🎉 GitLab DevOps stack deployed!"
echo "🌐 GitLab: http://gitlab.local"
echo "🗄️ Database: PostgreSQL"
echo "🏃 Runner: Ready for CI/CD"
echo "🔧 Runner configuration: ./setup-runner.sh"

# Continuous logs
docker compose logs -f gitlab
```

**✅ Result** : Complete DevOps platform with integrated CI/CD

---

# Compose Exercises Summary 📋

### Skills acquired with official images

**🟢 Simple Level** :
- WordPress + MySQL (official images)
- Volumes and persistence
- Environment variables
- Basic commands

**🟡 Intermediate Level** :
- NGINX + Node.js + Redis
- Custom networks
- Proxy configuration
- Service monitoring

---

# Compose Summary (continued) 📋

**🔴 Advanced Level** :
- Prometheus + Grafana stack (monitoring)
- Node Exporter + AlertManager
- Advanced configuration
- Health checks

**🔵 Expert Level** :
- GitLab CE + PostgreSQL + Runner
- Complete CI/CD platform
- DevOps infrastructure
- Automated pipelines

### 🚀 **Docker Compose mastered with real images!**

Next step: Ansible to automate deployment!
