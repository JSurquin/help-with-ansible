---
layout: default
routeAlias: 'mini-blog'
---

<a name="MINI_BLOG" id="MINI_BLOG"></a>

# Mini-Blog Project

## Project objective

Build a simple blog application using Angular 18 for the frontend, Node.js for the backend, MongoDB for the database, and Nginx as a reverse proxy. The stack will be containerized with Docker and deployed with Ansible.

---

# Project architecture

## Main components
- **Frontend**: Angular 18
  - Modern user interface
  - Routing and state management
  - Reusable components

- **Backend**: Node.js
  - RESTful API
  - JWT authentication
  - Data validation

---

# Architecture (continued)

## Main components
- **Database**: MongoDB
  - Article storage
  - User management
  - Optimized indexing

- **Infrastructure**: Docker + Nginx
  - Containerization
  - Load balancing
  - SSL/TLS

---

# Project structure

## File organization
```
mini-blog/
├── frontend/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── backend/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── docker-compose.yml
└── ansible/
    ├── inventory/
    ├── playbooks/
    └── roles/
```

---

# Frontend Configuration

## Angular 18
```typescript
// frontend/src/app/app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { RouterModule } from '@angular/router';

@NgModule({
  declarations: [
    AppComponent,
    ArticleListComponent,
    ArticleDetailComponent,
    LoginComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    RouterModule.forRoot([
      { path: '', component: ArticleListComponent },
      { path: 'article/:id', component: ArticleDetailComponent },
      { path: 'login', component: LoginComponent }
    ])
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

---

# Frontend configuration (continued)

## Dockerfile
```dockerfile
# frontend/Dockerfile
FROM node:20-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist/mini-blog /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

---

# Backend Configuration

## Node.js
```javascript
// backend/src/server.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

mongoose.connect('mongodb://db:27017/mini-blog');

const articleSchema = new mongoose.Schema({
  title: String,
  content: String,
  author: String,
  date: { type: Date, default: Date.now }
});

const Article = mongoose.model('Article', articleSchema);

app.get('/api/articles', async (req, res) => {
  const articles = await Article.find();
  res.json(articles);
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

---

# Backend configuration (continued)

## Dockerfile
```dockerfile
# backend/Dockerfile
FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "src/server.js"]
```

---

# Docker Compose Configuration

## docker-compose.yml
```yaml
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - MONGODB_URI=mongodb://db:27017/mini-blog
      - JWT_SECRET=your-secret-key
    depends_on:
      - db

  db:
    image: mongo:latest
    volumes:
      - mongodb_data:/data/db
    ports:
      - "27017:27017"

volumes:
  mongodb_data:
```

---

# Nginx Configuration

## nginx.conf
```nginx
# frontend/nginx.conf
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

# Ansible Configuration

## Main playbook
```yaml
# ansible/playbooks/deploy.yml
---
- name: Deploy Mini-Blog
  hosts: all
  become: yes
  tasks:
    - name: Install Docker
      include_role:
        name: docker

    - name: Install Docker Compose
      include_role:
        name: docker-compose

    - name: Deploy the application
      include_role:
        name: mini-blog
```

---

# Ansible Configuration (continued)

## mini-blog role
```yaml
# ansible/roles/mini-blog/tasks/main.yml
---
- name: Create application directory
  file:
    path: "{{ app_path }}"
    state: directory
    mode: '0755'

- name: Copy application files
  copy:
    src: "{{ item }}"
    dest: "{{ app_path }}"
  with_items:
    - docker-compose.yml
    - frontend
    - backend

- name: Start the application
  docker_compose:
    project_src: "{{ app_path }}"
    files:
      - docker-compose.yml
    state: present
```

---

# Blog features

## Articles
- Create articles
- Edit articles
- Delete articles
- List articles
- Search articles

## Users
- Registration
- Login
- User profile
- Permission management

---

# Security

## Security measures
- JWT authentication
- Data validation
- CSRF protection
- Rate limiting
- HTTPS/TLS

## Security configuration
```yaml
# backend/src/config/security.js
module.exports = {
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: '1h'
  },
  cors: {
    origin: process.env.FRONTEND_URL,
    credentials: true
  },
  rateLimit: {
    windowMs: 15 * 60 * 1000,
    max: 100
  }
};
```

---

# Monitoring

## Prometheus Configuration
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:3000']

  - job_name: 'frontend'
    static_configs:
      - targets: ['frontend:80']
```

## Grafana Configuration
```yaml
# monitoring/grafana/dashboards/blog.json
{
  "dashboard": {
    "title": "Mini-Blog Metrics",
    "panels": [
      {
        "title": "API Requests",
        "type": "graph",
        "datasource": "Prometheus"
      },
      {
        "title": "Response Time",
        "type": "graph",
        "datasource": "Prometheus"
      }
    ]
  }
}
```

---

# Tests

## Frontend Tests
```typescript
// frontend/src/app/article-list.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ArticleListComponent } from './article-list.component';

describe('ArticleListComponent', () => {
  let component: ArticleListComponent;
  let fixture: ComponentFixture<ArticleListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ArticleListComponent ]
    })
    .compileComponents();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
```

---

# Tests (continued)

## Backend Tests
```javascript
// backend/src/tests/article.test.js
const request = require('supertest');
const app = require('../server');

describe('Article API', () => {
  it('should get all articles', async () => {
    const res = await request(app)
      .get('/api/articles')
      .send();
    expect(res.statusCode).toEqual(200);
    expect(Array.isArray(res.body)).toBeTruthy();
  });
});
```

---

# Deployment

## Deployment steps
1. Environment preparation
   - Install Docker
   - Configure Nginx
   - Configure MongoDB

2. Application deployment
   - Build images
   - Configure containers
   - Start services

3. Verification
   - Functional tests
   - Performance tests
   - Monitoring

---

# Maintenance

## Maintenance tasks
- Update dependencies
- Database backup
- Log rotation
- Performance monitoring

## Maintenance scripts
```bash
#!/bin/bash
# maintenance/backup.sh
DATE=$(date +%Y%m%d)
docker exec mini-blog_db mongodump --out /backup/$DATE
docker cp mini-blog_db:/backup/$DATE ./backup/
```

---

# Documentation

## Technical documentation
- System architecture
- Service configuration
- Deployment procedures
- Maintenance procedures

## User documentation
- User guide
- FAQ
- Technical support
- Privacy policy 