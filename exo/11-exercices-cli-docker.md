---
layout: new-section
routeAlias: 'exercices-cli-docker'
---

<a name="EXERCICES_CLI" id="EXERCICES_CLI"></a>

# Docker CLI Exercises 🎯

### 3 progressive DevOps levels

Master Docker with **complete stacks**: networks + volumes + inter-container communication!

---

## Why these exercises? 🤔

### Learning objectives

- **🌐 Networks**: Make multiple containers communicate
- **💾 Volumes**: Persist and share data
- **🔧 Variables**: Configure your applications
- **👀 Monitoring**: See what is happening in real time
- **🚀 Production**: Prepare realistic environments

### What you will build today:
✅ Database with web interface  
✅ Complete WordPress site  
✅ Multi-distribution DevOps environment  
✅ Professional monitoring stack  

---

# 🟢 Beginner Level Exercise

## PostgreSQL + Web Interface Stack

### 🎯 **Goal**: Your first database with a web interface

**What you will learn**:
- Create and use Docker **networks**
- Persist data with **volumes**
- Connect containers to each other
- Get **visual feedback** from your database

---

### 📚 **What is PostgreSQL?**

**PostgreSQL** is a very popular relational database:
- More modern than MySQL in some aspects
- Used by Instagram, Spotify, Reddit
- Excellent for learning and production

**phpPgAdmin** is a web interface for PostgreSQL:
- Equivalent to phpMyAdmin but for PostgreSQL
- Lets you create tables and view data visually
- Perfect for getting started without the command line

---

### 🔧 **Step 1: Prepare the environment**

```bash
# Create the network so containers can talk to each other
docker network create db-network

# Create volumes for persistence
docker volume create postgres-data
docker volume create postgres-logs

# Verify everything was created
docker network ls | grep db-network
docker volume ls | grep postgres
```

**💡 Why do this?**
- **Network**: Containers can talk to each other by name
- **Volumes**: Your data will survive restarts
- **Organization**: Clean, reusable structure

---

### 🔧 **Step 2: Start PostgreSQL**

```bash
# Start PostgreSQL with full configuration
docker run -d \
  --name my-postgres \
  --network db-network \
  -e POSTGRES_DB=formation \
  -e POSTGRES_USER=docker \
  -e POSTGRES_PASSWORD=formation123 \
  -v postgres-data:/var/lib/postgresql/data \
  -v postgres-logs:/var/log/postgresql \
  -p 5432:5432 \
  postgres:15-alpine
```

---

### 📋 **PostgreSQL command explained**

```bash
# Let's break down each option:

--name my-postgres          # Container name (for reference)
--network db-network        # Joins our custom network
-e POSTGRES_DB=formation     # Creates a "formation" database
-e POSTGRES_USER=docker      # User with admin rights
-e POSTGRES_PASSWORD=...     # Password (REQUIRED!)
-v postgres-data:/var/lib... # Volume for data
-v postgres-logs:/var/log... # Volume for logs
-p 5432:5432                # Port accessible from your PC
postgres:15-alpine          # Official image, lightweight version
```

---

### 🔧 **Step 3: Verify PostgreSQL is running**

```bash
# Wait 5 seconds for PostgreSQL to start
echo "⏳ PostgreSQL starting..."
sleep 5

# Check status
docker ps | grep postgres

# View startup logs
docker logs my-postgres

# Test the connection
docker exec my-postgres pg_isready -U docker
```

**✅ What to look for**: 
- Container in "Up" status
- Logs without "database system is ready" errors
- "accepting connections" message

---

### 🔧 **Step 4: Start the phpPgAdmin web interface**

```bash
# Web interface to manage PostgreSQL
docker run -d \
  --name phppgadmin \
  --network db-network \
  -e POSTGRES_HOST=my-postgres \
  -e POSTGRES_PORT=5432 \
  -p 8081:80 \
  dockage/phppgadmin:latest
```

---

### 📋 **phpPgAdmin explained**

```bash
# Let's break down this command:

--name phppgadmin           # Web interface name
--network db-network        # Same network as PostgreSQL
-e POSTGRES_HOST=my-postgres # Connects to our database
-e POSTGRES_PORT=5432       # Standard PostgreSQL port
-p 8081:80                  # Interface accessible on port 8081
dockage/phppgadmin:latest   # Image with web interface
```

**🌐 Network magic**: phpPgAdmin can reach `my-postgres` by name!

---

### 🎉 **Step 5: Test your stack!**

```bash
# Verify everything is running
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🎯 YOUR STACK IS READY!"
echo "🌐 Web interface: http://localhost:8081"
echo "👤 Server: my-postgres"
echo "🔑 User: docker"
echo "🔐 Password: formation123"
echo ""
echo "📊 Open your browser and log in!"
```

---

### 🧪 **Step 6: Experiment with data**

**In the web interface** (http://localhost:8081):
1. **Log in** with the credentials
2. **Create a table** `utilisateurs` 
3. **Add some data**
4. **Restart PostgreSQL**: `docker restart my-postgres`
5. **Verify** your data is still there!

```bash
# Restart test
docker restart my-postgres
sleep 5
echo "🔄 PostgreSQL restarted — is your data still there?"
```

---

### 🔍 **Step 7: Explore volumes**

```bash
# See where Docker stores your data
docker volume inspect postgres-data

# See space used
docker system df

# View database files (from inside the container)
docker exec my-postgres ls -la /var/lib/postgresql/data
```

**💡 Understand**: Your data is **physically** stored on your disk, not inside the container!

---

### 🧹 **Step 8: Cleanup (optional)**

```bash
# Script to remove everything cleanly
echo "🧹 Cleaning up the PostgreSQL stack..."

# Stop containers
docker stop phppgadmin my-postgres

# Remove containers
docker rm phppgadmin my-postgres

# Remove network
docker network rm db-network

# Remove volumes (WARNING: data loss!)
docker volume rm postgres-data postgres-logs

echo "✅ PostgreSQL stack removed"
```

---

### 🏆 **Beginner Level Summary**

**✅ You have mastered**:
- Creating custom Docker **networks**
- Using **volumes** for persistence
- Connecting **containers** to each other
- Configuring with **environment variables**
- Having a **visual interface** for your data

**🚀 Ready for the intermediate level!**

---

# 🟡 Intermediate Level Exercise

## Complete WordPress Stack

### 🎯 **Goal**: Professional website with database

**What you will build**:
- Complete, functional **WordPress** site
- Dedicated **MySQL** database
- **phpMyAdmin** interface to manage the DB
- Persistent **volumes** to save everything
- Secure **network** between services

---

### 📚 **What is WordPress?**

**WordPress** is the world's most popular CMS:
- Powers about **40% of websites** worldwide
- Intuitive admin interface
- Thousands of themes and plugins
- Perfect for blogs, showcase sites, e-commerce

**MySQL** is its preferred database:
- Stores articles, users, comments
- Very widespread relational database
- **phpMyAdmin** lets you manage it visually

---

### 🔧 **Step 1: Create the WordPress environment**

```bash
# Environment dedicated to WordPress
docker network create wordpress-network
docker volume create mysql-data
docker volume create wordpress-data

# Verify creation
echo "🌐 Network created:"
docker network ls | grep wordpress

echo "💾 Volumes created:"
docker volume ls | grep -E "(mysql|wordpress)"
```

---

### 🔧 **Step 2: Start MySQL for WordPress**

```bash
# MySQL database optimized for WordPress
docker run -d \
  --name mysql-wordpress \
  --network wordpress-network \
  -e MYSQL_ROOT_PASSWORD=root123 \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppass \
  -v mysql-data:/var/lib/mysql \
  --restart unless-stopped \
  mysql:8.0
```

---

### 📋 **MySQL configuration explained**

```bash
# Let's analyze this MySQL configuration:

-e MYSQL_ROOT_PASSWORD=root123    # Administrator password
-e MYSQL_DATABASE=wordpress       # Database dedicated to WordPress
-e MYSQL_USER=wpuser             # WordPress user
-e MYSQL_PASSWORD=wppass         # Their password
-v mysql-data:/var/lib/mysql     # Data persistence
--restart unless-stopped         # Auto-restart (except manual stop)
mysql:8.0                        # Stable MySQL version
```

**🔒 Security**: WordPress only has access to its database, not others!

---

### 🔧 **Step 3: Wait for MySQL to be ready**

```bash
# MySQL takes time to start
echo "⏳ Starting MySQL (may take 30 seconds)..."
sleep 15

# Verify MySQL accepts connections
docker exec mysql-wordpress mysqladmin ping -h localhost

# View startup logs
docker logs mysql-wordpress --tail 10
```

**💡 Why wait?** MySQL must initialize the `wordpress` database before WordPress connects!

---

### 🔧 **Step 4: Start WordPress**

```bash
# WordPress connected to MySQL
docker run -d \
  --name my-wordpress \
  --network wordpress-network \
  -e WORDPRESS_DB_HOST=mysql-wordpress \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppass \
  -e WORDPRESS_DB_NAME=wordpress \
  -v wordpress-data:/var/www/html \
  -p 8080:80 \
  --restart unless-stopped \
  wordpress:latest
```

---

### 📋 **WordPress configuration explained**

```bash
# WordPress configuration:

-e WORDPRESS_DB_HOST=mysql-wordpress  # Connects to our MySQL
-e WORDPRESS_DB_USER=wpuser          # Uses our user
-e WORDPRESS_DB_PASSWORD=wppass      # With the correct password
-e WORDPRESS_DB_NAME=wordpress       # In the right database
-v wordpress-data:/var/www/html      # Persistent WordPress files
-p 8080:80                          # Accessible on port 8080
```

**🌐 Network magic**: WordPress finds MySQL via the name `mysql-wordpress`!

---

### 🔧 **Step 5: Add phpMyAdmin for the database**

```bash
# Interface to manage the MySQL database
docker run -d \
  --name mysql-admin \
  --network wordpress-network \
  -e PMA_HOST=mysql-wordpress \
  -e PMA_USER=root \
  -e PMA_PASSWORD=root123 \
  -p 8081:80 \
  phpmyadmin:latest

echo "📊 phpMyAdmin available at: http://localhost:8081"
```

---

### 🎉 **Step 6: Test your WordPress stack!**

```bash
# Verify all services
echo "🔍 Status of your WordPress stack:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(wordpress|mysql)"

echo ""
echo "🎯 YOUR WORDPRESS STACK IS READY!"
echo ""
echo "🌐 WordPress: http://localhost:8080"
echo "📊 phpMyAdmin: http://localhost:8081"
echo "   👤 User: root | Password: root123"
echo ""
echo "🚀 Install WordPress by following the setup wizard!"
```

---

### 🧪 **Step 7: Complete WordPress installation**

**In your browser**:

1. **Go to** http://localhost:8080
2. **Follow the** WordPress installation wizard
3. **Create your** administrator account
4. **Log in** to the WordPress dashboard

```bash
# During installation, watch the logs
docker logs my-wordpress --follow
```

**🎉 First post**: Create a post "Hello Docker World!" to test!

---

### 🔍 **Step 8: Explore the database**

**In phpMyAdmin** (http://localhost:8081):

1. **Log in** with root/root123
2. **Select** the `wordpress` database
3. **Explore** WordPress tables (wp_posts, wp_users, etc.)
4. **Find** your post in `wp_posts`!

```bash
# View WordPress tables from the terminal
docker exec mysql-wordpress mysql -u wpuser -pwppass wordpress -e "SHOW TABLES;"
```

---

### 🔄 **Step 9: Persistence test**

```bash
# Ultimate test: restart the entire stack
echo "🔄 Persistence test — restarting everything..."

docker restart mysql-wordpress my-wordpress mysql-admin

# Wait for restart
sleep 20

echo "✅ Stack restarted!"
echo "🌐 Your site: http://localhost:8080"
echo "📊 Your database: http://localhost:8081"
echo ""
echo "🎯 Is your data still there?"
```

---

### 🏆 **Intermediate Level Summary**

**✅ You have mastered**:
- Complete, functional **multi-container stack**
- Secure **communication** via custom network
- Full **persistence** with dedicated volumes
- **Environment variables** for configuration
- **Admin interface** for the database
- **Restart policies** for robustness

**🚀 Advanced level: DevOps environments!**

---

# 🔴 Advanced Level Exercise

## Multi-Distribution DevOps Environment

### 🎯 **Goal**: Simulate a DevOps production environment

**What you will build**:
- **Cluster** of containers with different Linux distributions
- **Shared workspace** across all containers
- **Centralized logs** for monitoring
- **DevOps tools** installed and configured
- **Inter-container communication** tested

---

### 📚 **Why multiple distributions?**

**In DevOps production** you often manage:
- **CentOS/RHEL**: Traditional enterprise servers
- **Fedora**: Development environments with recent tools
- **Rocky Linux**: Modern alternative to CentOS
- **Alpine**: Ultra-lightweight containers for microservices

**This exercise simulates**:
- Realistic **heterogeneous** environment
- **File sharing** between servers
- **Log centralization** as in production
- **Tools** you would actually use

---

### 🔧 **Step 1: Create the DevOps environment**

```bash
# DevOps infrastructure
docker network create devops-network
docker volume create shared-workspace
docker volume create logs-centralized
docker volume create tools-shared

# Create a local working directory
mkdir -p ~/docker-devops
cd ~/docker-devops

echo "🏗️ DevOps infrastructure created"
docker network ls | grep devops
docker volume ls | grep -E "(shared|logs|tools)"
```

---

### 🔧 **Step 2: CentOS Container - Legacy Server**

```bash
# CentOS server with traditional DevOps tools
docker run -d \
  --name centos-legacy \
  --network devops-network \
  -v shared-workspace:/workspace \
  -v logs-centralized:/var/log/shared \
  -v tools-shared:/opt/tools \
  --hostname centos-srv \
  --privileged \
  centos:7 \
  /bin/bash -c "
    yum update -y && 
    yum install -y git vim curl wget htop net-tools &&
    echo 'CentOS Legacy Server Ready' > /var/log/shared/centos.log &&
    tail -f /dev/null
  "
```

---

### 📋 **CentOS configuration explained**

```bash
# Let's analyze this CentOS container:

--hostname centos-srv              # Identifiable network name
--privileged                      # Extended access (required for some tools)
-v shared-workspace:/workspace     # Shared folder for projects
-v logs-centralized:/var/log/shared # Centralized logs
-v tools-shared:/opt/tools         # Shared tools
yum install -y git vim curl...     # Essential DevOps tools
echo '...' > /var/log/shared/...   # Startup log
tail -f /dev/null                  # Keeps the container running
```

---

### 🔧 **Step 3: Fedora Container - Modern Environment**

```bash
# Fedora with modern development tools
docker run -d \
  --name fedora-modern \
  --network devops-network \
  -v shared-workspace:/workspace \
  -v logs-centralized:/var/log/shared \
  -v tools-shared:/opt/tools \
  --hostname fedora-dev \
  -p 9090:9090 \
  fedora:38 \
  /bin/bash -c "
    dnf update -y && 
    dnf install -y git vim curl wget htop python3 nodejs npm docker &&
    echo 'Fedora Modern Environment Ready' > /var/log/shared/fedora.log &&
    python3 -m http.server 9090 --directory /workspace &
    tail -f /dev/null
  "
```

**🚀 Bonus**: Fedora exposes a web server on port 9090 to share files!

---

### 🔧 **Step 4: Rocky Linux Container - Production Server**

```bash
# Rocky Linux as production web server
docker run -d \
  --name rocky-production \
  --network devops-network \
  -v shared-workspace:/workspace \
  -v logs-centralized:/var/log/shared \
  -v tools-shared:/opt/tools \
  --hostname rocky-prod \
  -p 8080:80 \
  rockylinux:9 \
  /bin/bash -c "
    dnf install -y httpd git curl vim &&
    echo '<h1>🐳 Rocky Linux Production Server</h1><p>Shared workspace available</p>' > /var/www/html/index.html &&
    echo 'Rocky Production Server Ready' > /var/log/shared/rocky.log &&
    httpd -D FOREGROUND
  "
```

**🌐 Web server**: Rocky Linux exposes an HTTP server on port 8080!

---

### 🔧 **Step 5: Wait for everything to start**

```bash
# Give time for package installations
echo "⏳ Installing packages on all distributions..."
sleep 30

# Verify all containers are running
echo "🔍 DevOps environment status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(centos|fedora|rocky)"

echo ""
echo "🌐 Exposed services:"
echo "📁 File sharing (Fedora): http://localhost:9090"
echo "🌐 Web server (Rocky): http://localhost:8080"
```

---

### 🧪 **Step 6: Test inter-container communication**

```bash
# Network connectivity test
echo "🌐 Testing inter-container communication:"

# CentOS ping Fedora
docker exec centos-legacy ping -c 3 fedora-dev

# Fedora ping Rocky
docker exec fedora-modern ping -c 3 rocky-prod

# Rocky ping CentOS
docker exec rocky-production ping -c 3 centos-srv

echo "✅ Network communication tested!"
```

---

### 🧪 **Step 7: Test the shared workspace**

```bash
# Create a file from CentOS
docker exec centos-legacy bash -c "
  echo '# DevOps Project 2026' > /workspace/README.md
  echo 'This file is shared across all containers' >> /workspace/README.md
  echo 'Created from CentOS Legacy' >> /workspace/README.md
  date >> /workspace/README.md
"

# Read it from Fedora
echo "📖 Content read from Fedora:"
docker exec fedora-modern cat /workspace/README.md

# Modify it from Rocky
docker exec rocky-production bash -c "
  echo 'Modified from Rocky Production' >> /workspace/README.md
"

# Verify from CentOS
echo ""
echo "📖 Final content read from CentOS:"
docker exec centos-legacy cat /workspace/README.md
```

---

### 🔍 **Step 8: Explore centralized logs**

```bash
# View all startup logs
echo "📋 Centralized logs from all distributions:"
docker exec centos-legacy ls -la /var/log/shared/

echo ""
echo "📄 Log contents:"
docker exec centos-legacy cat /var/log/shared/centos.log
docker exec fedora-modern cat /var/log/shared/fedora.log  
docker exec rocky-production cat /var/log/shared/rocky.log

# Add a custom log
docker exec fedora-modern bash -c "
  echo 'Monitoring test - $(date)' >> /var/log/shared/monitoring.log
"
```

---

### 🎯 **Step 9: Realistic DevOps simulation**

```bash
# Create a shared deployment script
docker exec centos-legacy bash -c "
#!/bin/bash
echo '🚀 Automated deployment'
echo 'Server: \$(hostname)'
echo 'Distribution: \$(cat /etc/os-release | grep PRETTY_NAME)'
echo 'Date: \$(date)'
echo 'User: \$(whoami)'
echo '✅ Deployment complete'
chmod +x /workspace/deploy.sh
"

# Run the script from each distribution
echo "🚀 Running the deployment script:"
echo ""
echo "--- CentOS Legacy ---"
docker exec centos-legacy /workspace/deploy.sh

echo ""
echo "--- Fedora Modern ---"
docker exec fedora-modern /workspace/deploy.sh

echo ""  
echo "--- Rocky Production ---"
docker exec rocky-production /workspace/deploy.sh
```

---

### 🏆 **Advanced Level Summary**

**✅ DevOps environment mastered**:
- **Multi-distribution** Linux in communication
- **Shared workspace** for common projects
- **Centralized logs** for monitoring
- **Cross-platform deployment scripts**
- Realistic **production simulation**

**🔥 Ready for the expert level with monitoring!**

---

# 🔥 BONUS Exercise - Expert

## Professional Monitoring Stack

### 🎯 **Goal**: Production-grade monitoring

**What you will build**:
- **Prometheus**: Metrics collection
- **Grafana**: Beautiful visual dashboards  
- **cAdvisor**: Container metrics
- Complete **production monitoring** stack

---

### 📚 **What is modern monitoring?**

**Prometheus** 🔍 :
- **Time-series metrics** database
- Used by Google, SoundCloud, DigitalOcean
- Automatic collection from your applications
- Built-in **alerting** system

**Grafana** 📊 :
- Beautiful, interactive **dashboards**
- Real-time graphs
- Used by PayPal, eBay, Intel
- Modern, intuitive web interface

---

### 🔧 **Step 1: Prepare the monitoring environment**

```bash
# Monitoring infrastructure
docker network create monitoring-network
docker volume create prometheus-data
docker volume create grafana-data

# Create the configuration directory
mkdir -p ~/monitoring-stack
cd ~/monitoring-stack

echo "📊 Monitoring infrastructure created"
```

---

### 🔧 **Step 2: Prometheus configuration**

```bash
# Create Prometheus configuration
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

echo "⚙️ Prometheus configuration created"
```

**📋 Configuration explained**:
- `scrape_interval: 15s`: Collects metrics every 15 seconds
- Monitors **Prometheus itself** and **cAdvisor**

---

### 🔧 **Step 3: Start Prometheus**

```bash
# Prometheus with custom configuration
docker run -d \
  --name prometheus \
  --network monitoring-network \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v prometheus-data:/prometheus \
  --restart unless-stopped \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles \
  --web.enable-lifecycle
```

---

### 🔧 **Step 4: Start cAdvisor (container metrics)**

```bash
# Node Exporter for system metrics
docker run -d \
  --name node-exporter \
  --network monitoring-network \
  -p 9100:9100 \
  --restart unless-stopped \
  prom/node-exporter:latest \
  --path.rootfs=/host \
  --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($$|/)"
```

---

### 🔧 **Step 5: Start Prometheus**

```bash
# Prometheus with custom configuration
docker run -d \
  --name cadvisor \
  --network monitoring-network \
  -p 8080:8080 \
  --restart unless-stopped \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  gcr.io/cadvisor/cadvisor:latest
```

**🐳 What is cAdvisor?**
- Developed by **Google** to monitor containers
- Collects metrics from **all your Docker containers**
- CPU, RAM, network, I/O per container

---

### 🔧 **Step 6: Start Grafana with dashboard**

```bash
# Grafana with persistent storage
docker run -d \
  --name grafana \
  --network monitoring-network \
  -p 3000:3000 \
  -v grafana-data:/var/lib/grafana \
  -e GF_SECURITY_ADMIN_PASSWORD=admin123 \
  -e GF_USERS_ALLOW_SIGN_UP=false \
  --restart unless-stopped \
  grafana/grafana:latest
```

**🎨 Grafana** will create beautiful graphs with all these metrics!

---

### 🎉 **Step 7: Verify your monitoring stack**

```bash
# Wait for everything to start
echo "⏳ Starting the monitoring stack (30 seconds)..."
sleep 30

# Verify all services
echo "📊 Status of your monitoring stack:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(prometheus|grafana|node-exporter|cadvisor)"

echo ""
echo "🎯 MONITORING STACK READY!"
echo ""
echo "📈 Prometheus: http://localhost:9090"
echo "📊 Grafana: http://localhost:3000"
echo "   👤 User: admin | Password: admin123"
echo "🐳 cAdvisor: http://localhost:8080"
echo ""
echo "🚀 Now configure your Grafana dashboards!"
```

---

### 🎨 **Step 8: Grafana configuration (Hands-on)**

**In Grafana** (http://localhost:3000):

1. **Log in** with admin/admin123
2. **Add Prometheus** as a data source:
   - URL: `http://prometheus:9090`   
   - Click "Save & Test"

3. **Import preconfigured dashboards**:
   - Docker containers: Dashboard ID `193`

```bash
# While you configure, watch the metrics
echo "📈 Metrics being collected..."
docker logs prometheus --tail 10
```

---

### 🧪 **Step 9: Generate activity to monitor**

```bash
# Create activity to see metrics move
echo "🔥 Generating activity for monitoring..."

# Start a few resource-hungry containers
docker run -d --name stress-test alpine:latest \
  sh -c "while true; do echo 'generating load...'; sleep 1; done"

docker run -d --name cpu-test alpine:latest \
  sh -c "while true; do dd if=/dev/zero of=/dev/null bs=1M count=100; done"

# Monitor in real time
echo "📊 Watch your Grafana dashboards now!"
echo "🔍 You should see CPU and container activity increase"
```

---

### 🔍 **Step 10: Exploring metrics**

**In Prometheus** (http://localhost:9090):

1. **Explore available metrics**
2. **Try these queries** in the "Graph" tab:

```bash
# CPU usage
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
100 * (1 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)))

# Container count
count(container_last_seen)
```

---

### 🏆 **Congratulations! Expert Stack Mastered**

**✅ You have built a professional monitoring infrastructure**:

- **Prometheus**: Metrics database like Netflix, Uber
- **Grafana**: Visual dashboards like Tesla, PayPal  
- **cAdvisor**: Container monitoring by Google
- **Production-ready configuration** with persistence

**🎯 Skills acquired**:
- Modern **observability** architecture
- **Time-series database** configuration  
- Professional interactive **dashboards**
- System and container **metrics**
- **Stack** used in the real world

---

# 🎉 Complete Exercise Recap

<small>

### 🟢 **Beginner Level - Database**
- Custom Docker networks
- Persistent volumes  
- Inter-container communication
- Web interface for databases

### 🟡 **Intermediate Level - Complete website**
- Multi-container stack (WordPress + MySQL)
- Advanced environment variables
- Restart policies
- Database administration

</small>

---

<small>

### 🔴 **Advanced Level - Multi-distribution DevOps**  
- Heterogeneous Linux environment
- Shared workspace
- Centralized logs
- Cross-platform scripts

### 🔥 **Expert Level - Professional monitoring**
- Prometheus + Grafana
- System and container metrics
- Interactive dashboards
- Production observability

</small>


---

## 🚀 **You are now ready for Docker Compose!**

### These exercises have prepared you to:
- **Orchestrate** complex applications
- **Manage** multi-service environments
- **Monitor** your infrastructures
- **Automate** your deployments

**Next module**: Docker Compose to simplify all of this! 🎼
