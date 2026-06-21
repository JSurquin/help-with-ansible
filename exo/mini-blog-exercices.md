---
layout: default
routeAlias: 'mini-blog-exercices'
---

<a name="MINI_BLOG_EXERCICES" id="MINI_BLOG_EXERCICES"></a>

# Mini-Blog Exercises

## Module 1: Introduction to Docker

### Exercise 1.1: Create an Nginx container
```bash
# Create an Nginx container
docker run -d --name nginx -p 80:80 nginx

# Check status
docker ps

# Access the container
docker exec -it nginx bash
```

### Exercise 1.2: Dockerfile for a simple application
```dockerfile
# Create a Dockerfile for a Node.js application
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```

---

# Exercises (continued)

## Module 2: Docker Compose

### Exercise 2.1: Basic configuration
```yaml
# Create a docker-compose.yml for the frontend
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "4200:4200"
    volumes:
      - ./frontend:/app
      - /app/node_modules
```

### Exercise 2.2: Volumes and networks
```yaml
# Add volumes and networks
version: '3.8'
services:
  frontend:
    # ... previous configuration ...
    networks:
      - frontend
    volumes:
      - frontend_data:/app/data

  backend:
    build: ./backend
    networks:
      - frontend
      - backend
    volumes:
      - backend_data:/app/data

volumes:
  frontend_data:
  backend_data:

networks:
  frontend:
  backend:
```

---

# Exercises (continued)

## Module 3: CI/CD

### Exercise 3.1: GitHub Actions pipeline
```yaml
# Create a CI/CD pipeline
name: CI/CD Pipeline
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and Test
        run: |
          docker-compose build
          docker-compose up -d
          npm test
```

### Exercise 3.2: Automatic deployment
```yaml
# Add deployment
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: |
          ansible-playbook deploy.yml
```

---

# Exercises (continued)

## Module 4: Ansible

### Exercise 4.1: Basic playbook
```yaml
# Create a playbook for installation
---
- name: Install Docker
  hosts: all
  become: yes
  tasks:
    - name: Install prerequisites
      apt:
        name: "{{ packages }}"
        state: present
      vars:
        packages:
          - docker.io
          - docker-compose
```

### Exercise 4.2: Application deployment
```yaml
# Add deployment
    - name: Deploy the application
      docker_compose:
        project_src: "{{ app_path }}"
        files:
          - docker-compose.yml
        state: present
```

---

# Exercises (continued)

## Module 5: Security

### Exercise 5.1: Container hardening
```yaml
# Add security rules
version: '3.8'
services:
  frontend:
    # ... previous configuration ...
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

### Exercise 5.2: SSL/TLS configuration
```nginx
# Configure Nginx with SSL
server {
    listen 443 ssl;
    server_name example.com;
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    # ... additional configuration ...
}
```

---

# Exercises (continued)

## Module 6: Advanced

### Exercise 6.1: Image optimization
```dockerfile
# Optimize a Docker image
FROM node:20-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

### Exercise 6.2: Scaling and load balancing
```yaml
# Configure scaling
version: '3.8'
services:
  frontend:
    # ... previous configuration ...
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
```

---

# Practical exercises

## Exercise 1: Create an article
1. Create an Angular component for article editing
2. Implement the form with validation
3. Connect to the backend with HttpClient
4. Handle errors and user feedback

## Exercise 2: Authentication
1. Create an authentication service
2. Implement JWT in the backend
3. Add route guards
4. Handle refresh tokens

---

# Practical exercises (continued)

## Exercise 3: Media management
1. Create an upload service
2. Configure file storage
3. Implement preview
4. Manage permissions

## Exercise 4: Search and filtering
1. Implement frontend search
2. Add backend filters
3. Optimize MongoDB queries
4. Add pagination

---

# Deployment exercises

## Exercise 1: Development environment
1. Configure Docker Compose for development
2. Set up hot reloads
3. Configure environment variables
4. Add debugging tools

## Exercise 2: Production environment
1. Configure Nginx for production
2. Set up SSL/TLS
3. Configure backups
4. Set up monitoring

---

# Monitoring exercises

## Exercise 1: Prometheus configuration
1. Install and configure Prometheus
2. Add required exporters
3. Configure alerts
4. Visualize metrics

## Exercise 2: Grafana configuration
1. Install and configure Grafana
2. Create dashboards
3. Configure alerts
4. Set up notifications

---

# Security exercises

## Exercise 1: API hardening
1. Implement rate limiting
2. Add data validation
3. Set up CORS
4. Configure security headers

## Exercise 2: Container hardening
1. Configure capabilities
2. Set up security contexts
3. Configure network policies
4. Implement log rotation

---

# Maintenance exercises

## Exercise 1: Dependency management
1. Update dependencies
2. Manage vulnerabilities
3. Implement regression tests
4. Document changes

## Exercise 2: Backup and restore
1. Configure automatic backups
2. Implement backup rotation
3. Test restoration
4. Document procedures
