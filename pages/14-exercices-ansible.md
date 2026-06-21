---
layout: new-section
routeAlias: 'exercices-ansible'
---

<a name="EXERCICES_ANSIBLE" id="EXERCICES_ANSIBLE"></a>

# Ansible Exercises 🤖

### 3 progressive levels aligned with examples

Put into practice what you learned with Nginx!

---

# 🎯 Exercises overview

### Educational progression

The exercises follow **exactly** the same logic as the examples:

| Exercise | Based on | Concepts practiced |
|----------|----------|-------------------|
| 🟢 Simple | Example 1 | Inventory + Basic playbook |
| 🟡 Intermediate | Example 2 | Variables + Jinja2 templates |
| 🔴 Advanced | Example 3 + 4 | Roles + Production project |

**The goal**: You'll redo the examples yourself, without copy-pasting!

---

# 📋 Prerequisites for all exercises

### Test infrastructure

```bash
# 1. Start the Docker lab (if not already done)
docker-compose -f docker-compose-lab.yml up -d

# 2. Check that containers are up
docker ps | grep ansible-lab

# 3. Install Ansible (if not already done)
pip3 install ansible

# 4. Create your working directory
mkdir -p ansible-exercises
cd ansible-exercises
```

**💡 Reminder**: Docker containers simulate real Linux servers.

---

## 🟢 Simple Level Exercise

### Mission: Reproduce example 1 by yourself

**Objective**: Create a playbook that installs and configures Nginx on a web server

**What you need to create**:
1. An `inventory.yml` file with a web server
2. A playbook `install-nginx.yml`
3. Install Nginx
4. Start the service
5. Display a confirmation message

---

## 🟢 Detailed instructions

### Step 1: Create the inventory

Create `inventory.yml` with:
- A server named `web01`
- `ansible_host: ansible-lab-web01`
- `ansible_connection: docker`
- `ansible_user: root`

### Step 2: Create the playbook

Create `install-nginx.yml` with:
- Target: `hosts: all`
- `become: true`
- Variables: `nginx_port: 80` and `server_name: web01`

---

## 🟢 Detailed instructions (continued)

### Step 3: Tasks to create

Your playbook must contain these tasks:
1. Update APT cache
2. Install the nginx package
3. Start and enable the nginx service
4. Display a message with server info

**⏱️ Estimated time**: 15-20 minutes

**🎯 Test**: `ansible-playbook -i inventory.yml install-nginx.yml`

---

## 🟢 Solution - Inventory

```yaml
# inventory.yml
all:
  vars:
    ansible_connection: docker
    ansible_user: root
    ansible_python_interpreter: /usr/bin/python3

  hosts:
    web01:
      ansible_host: ansible-lab-web01
```

---

## 🟢 Solution - Playbook

```yaml
# install-nginx.yml
---
- name: Nginx installation and configuration
  hosts: all
  become: true
  
  vars:
    nginx_port: 80
    server_name: web01
  
  tasks:
    - name: Update APT cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Install Nginx
      apt:
        name: nginx
        state: present
```

---

## 🟢 Solution - Playbook (continued)

```yaml
    - name: Start and enable Nginx
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Display information
      debug:
        msg: |
          ✅ Nginx successfully installed!
          🌐 Server: {{ server_name }}
          📍 Port: {{ nginx_port }}
          🔗 Container: {{ ansible_host }}
```

---

## 🟢 Testing the exercise

```bash
# Execute the playbook
ansible-playbook -i inventory.yml install-nginx.yml

# Check that Nginx is running (with service in Docker)
docker exec ansible-lab-web01 service nginx status

# Test the default page
docker exec ansible-lab-web01 curl localhost
```

💡 **Note**: In Docker containers, we use `service` instead of `systemctl`

**✅ Expected result**: Nginx installed and functional!

---

## 🟡 Intermediate Level Exercise

### Mission: Variables + Templates (like example 2)

**Objective**: Deploy Nginx with custom configuration on multiple servers

**What you need to create**:
1. Inventory with 3 web servers (web01, web02, web03)
2. Variables file `group_vars/all.yml`
3. Template `nginx.conf.j2`
4. Custom template `index.html.j2`
5. Playbook with handlers

---

## 🟡 Detailed instructions

### Step 1: Project structure

Create this structure:
```
exercise-intermediate/
├── inventory.yml
├── group_vars/
│   └── all.yml
├── templates/
│   ├── nginx.conf.j2
│   └── index.html.j2
└── deploy.yml
```

---

## 🟡 Step 2: Multi-server inventory

Create an inventory with:
- A group `webservers`
- 3 servers: web01, web02, web03
- All pointing to `ansible-lab-web01`, `ansible-lab-web02`, `ansible-lab-web03`

### Step 3: Variables

In `group_vars/all.yml`, define:
- `app_name`: Your application name
- `app_version`: "1.0.0"
- `app_environment`: "development"
- `nginx_config` with port, worker_connections, client_max_body_size

---

## 🟡 Step 4: Templates to create

### nginx.conf.j2 Template

Must contain:
- Number of workers (variable)
- Basic HTTP configuration
- Virtual host with variable port
- Location / serving /var/www/html
- Location /health for health check

**💡 Tip**: Get inspired by example 2!

---

## 🟡 Step 5: HTML Template

### index.html.j2 Template

Create a custom HTML page with:
- Title: `{{ app_name }}`
- Version display
- Environment display
- Server name display (inventory_hostname)
- Background color based on environment

**Color variables**:
- development: "#e3f2fd"
- staging: "#fff3e0"
- production: "#e8f5e8"

---

## 🟡 Step 6: Playbook with handlers

Your `deploy.yml` playbook must:
1. Install Nginx
2. Create the web directory
3. Generate nginx.conf from template
4. Generate index.html from template
5. Start Nginx
6. Notify a handler "Restart Nginx" if config changes

**⏱️ Estimated time**: 30-40 minutes

---

## 🟡 Solution - Inventory

```yaml
# inventory.yml
all:
  vars:
    ansible_connection: docker
    ansible_user: root
    ansible_python_interpreter: /usr/bin/python3

  children:
    webservers:
      hosts:
        web01:
          ansible_host: ansible-lab-web01
        web02:
          ansible_host: ansible-lab-web02
        web03:
          ansible_host: ansible-lab-web03
```

---

## 🟡 Solution - Variables

```yaml
# group_vars/all.yml
---
app_name: "My Web Application"
app_version: "1.0.0"
app_environment: "development"

nginx_config:
  port: 80
  worker_connections: 1024
  client_max_body_size: "10m"

company:
  name: "Andromed"
  url: "https://www.andromed.fr"

env_colors:
  development: "#e3f2fd"
  staging: "#fff3e0"
  production: "#e8f5e8"
```

---

## 🟡 Solution - Template nginx.conf.j2

```nginx
# templates/nginx.conf.j2
user www-data;
worker_processes {{ ansible_processor_vcpus | default(2) }};
pid /run/nginx.pid;

events {
    worker_connections {{ nginx_config.worker_connections }};
}

http {
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    client_max_body_size {{ nginx_config.client_max_body_size }};

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
```

---

## 🟡 Solution - nginx.conf.j2 (continued)

```nginx
    server {
        listen {{ nginx_config.port }};
        server_name {{ inventory_hostname }};

        root /var/www/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }

        location /health {
            access_log off;
            return 200 "OK";
            add_header Content-Type text/plain;
        }
    }
}
```

---

## 🟡 Solution - Template index.html.j2

```html
<!-- templates/index.html.j2 -->
<!DOCTYPE html>
<html>
<head>
    <title>{{ app_name }}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background-color: {{ env_colors[app_environment] }};
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            max-width: 600px;
            margin: 0 auto;
        }
```

---

## 🟡 Solution - index.html.j2 (continued)

```html
        h1 { color: #2196f3; }
        .info { margin: 20px 0; }
        .label { font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 {{ app_name }}</h1>
        <div class="info">
            <p><span class="label">Server:</span> {{ inventory_hostname }}</p>
            <p><span class="label">Version:</span> {{ app_version }}</p>
            <p><span class="label">Environment:</span> {{ app_environment }}</p>
            <p><span class="label">Date:</span> {{ ansible_date_time.date }}</p>
        </div>
        <hr>
        <small>Deployed with Ansible + {{ company.name }}</small>
    </div>
</body>
</html>
```

---

## 🟡 Solution - Playbook deploy.yml

```yaml
# deploy.yml
---
- name: Deployment with variables and templates
  hosts: webservers
  become: true
  
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes
    
    - name: Create web directory
      file:
        path: /var/www/html
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'
```

---

## 🟡 Solution - deploy.yml (continued)

```yaml
    - name: Configure Nginx with template
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'
        backup: yes
      notify: Restart Nginx
    
    - name: Deploy custom HTML page
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: '0644'
```

---

## 🟡 Solution - deploy.yml (end)

```yaml
    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Display information
      debug:
        msg: |
          ✅ Deployment completed for {{ inventory_hostname }}
          🌐 Application: {{ app_name }} v{{ app_version }}
          🏷️ Environment: {{ app_environment }}
  
  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

---

## 🟡 Testing the exercise

```bash
# Execute the playbook on all servers
ansible-playbook -i inventory.yml deploy.yml

# Check on each server
docker exec ansible-lab-web01 curl localhost
docker exec ansible-lab-web02 curl localhost
docker exec ansible-lab-web03 curl localhost

# Test the health check
docker exec ansible-lab-web01 curl localhost/health

# Test with another environment
ansible-playbook -i inventory.yml deploy.yml -e app_environment=production
```

**✅ Expected result**: 3 Nginx servers with custom pages!

---

## 🔴 Advanced Level Exercise

### Mission: Create a reusable Nginx role

**Objective**: Reproduce example 3 - Professional organization with roles

**What you need to create**:
1. Complete role structure for Nginx
2. Default variables
3. Modular templates
4. Handlers
5. Metadata
6. Multi-vhost support

---

## 🔴 Step 1: Project structure

Create this complete structure:
```
exercise-advanced/
├── inventory.yml
├── site.yml
├── group_vars/
│   └── all.yml
└── roles/
    └── nginx/
        ├── tasks/
        │   └── main.yml
        ├── handlers/
        │   └── main.yml
        ├── templates/
        │   ├── nginx.conf.j2
        │   └── vhost.conf.j2
        ├── defaults/
        │   └── main.yml
        └── meta/
            └── main.yml
```

---

## 🔴 Step 2: Role defaults

In `roles/nginx/defaults/main.yml`, define:
- `nginx_user: www-data`
- `nginx_worker_processes: auto`
- `nginx_conf_path: /etc/nginx/nginx.conf`
- `nginx_vhost_path: /etc/nginx/sites-available`
- `nginx_vhost_enabled_path: /etc/nginx/sites-enabled`
- `nginx_remove_default_vhost: true`
- `nginx_service_state: started`
- `nginx_service_enabled: true`
- `nginx_vhosts: []` (empty list by default)

---

## 🔴 Step 3: Role tasks

In `roles/nginx/tasks/main.yml`, create tasks:
1. Update APT cache
2. Install Nginx
3. Create necessary directories (loop)
4. Generate nginx.conf from template
5. Remove default vhost (if `nginx_remove_default_vhost`)
6. Configure virtual hosts (loop over `nginx_vhosts`)
7. Enable virtual hosts (symbolic links)
8. Create web directories for each vhost
9. Start and enable Nginx

**💡 Use tags**: packages, config, vhosts, service

---

## 🔴 Step 4: Handlers

In `roles/nginx/handlers/main.yml`:
- Handler "Reload Nginx": `state: reloaded`
- Handler "Restart Nginx": `state: restarted`

### Step 5: Metadata

In `roles/nginx/meta/main.yml`:
- Galaxy information (author, description)
- Minimum versions (ansible_version: 2.9)
- Supported platforms (Ubuntu 20.04, 22.04)

---

## 🔴 Step 6: Templates

### nginx.conf.j2 Template
Global Nginx configuration (similar to intermediate)

### vhost.conf.j2 Template
Virtual host configuration:
```nginx
server {
    listen {{ item.port | default(80) }};
    server_name {{ item.server_name }};
    root {{ item.root }};
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

---

## 🔴 Step 7: Main playbook

In `site.yml`:
```yaml
---
- name: Deployment with roles
  hosts: webservers
  become: true
  
  vars:
    nginx_vhosts:
      - server_name: "{{ inventory_hostname }}"
        root: "/var/www/html"
        port: 80
  
  roles:
    - role: nginx
      tags: ['nginx', 'webserver']
```

**⏱️ Estimated time**: 45-60 minutes

---

## 🔴 Solution - defaults/main.yml

```yaml
# roles/nginx/defaults/main.yml
---
# process user / worker tuning
nginx_user: www-data
nginx_worker_processes: auto

# config paths
nginx_conf_path: /etc/nginx/nginx.conf
nginx_vhost_path: /etc/nginx/sites-available
nginx_vhost_enabled_path: /etc/nginx/sites-enabled

# nginx tuning
nginx_remove_default_vhost: true
nginx_worker_connections: 1024
nginx_client_max_body_size: "10m"

# service target state
nginx_service_state: started
nginx_service_enabled: true

# virtual hosts (empty by default)
nginx_vhosts: []
```

---

## 🔴 Solution - tasks/main.yml (part 1)

```yaml
# roles/nginx/tasks/main.yml
---
- name: Update APT cache
  apt:
    update_cache: yes
    cache_valid_time: 3600
  tags: ['packages']

- name: Install Nginx
  apt:
    name: nginx
    state: present
  tags: ['packages']

- name: Create required directories
  file:
    path: "{{ item }}"
    state: directory
    owner: "{{ nginx_user }}"
    group: "{{ nginx_user }}"
    mode: '0755'
  loop:
    - "{{ nginx_vhost_path }}"
    - "{{ nginx_vhost_enabled_path }}"
  tags: ['config']
```

---

## 🔴 Solution - tasks/main.yml (part 2)

```yaml
- name: Configure Nginx (nginx.conf)
  template:
    src: nginx.conf.j2
    dest: "{{ nginx_conf_path }}"
    owner: root
    group: root
    mode: '0644'
    validate: 'nginx -t -c %s'
  notify: Reload Nginx
  tags: ['config']

- name: Remove default vhost
  file:
    path: "{{ nginx_vhost_enabled_path }}/default"
    state: absent
  when: nginx_remove_default_vhost
  notify: Reload Nginx
  tags: ['config']
```

---

## 🔴 Solution - tasks/main.yml (part 3)

```yaml
- name: Configure virtual hosts
  template:
    src: vhost.conf.j2
    dest: "{{ nginx_vhost_path }}/{{ item.server_name }}.conf"
    owner: root
    group: root
    mode: '0644'
  loop: "{{ nginx_vhosts }}"
  when: nginx_vhosts | length > 0
  notify: Reload Nginx
  tags: ['config', 'vhosts']

- name: Enable virtual hosts
  file:
    src: "{{ nginx_vhost_path }}/{{ item.server_name }}.conf"
    dest: "{{ nginx_vhost_enabled_path }}/{{ item.server_name }}.conf"
    state: link
  loop: "{{ nginx_vhosts }}"
  when: nginx_vhosts | length > 0
  notify: Reload Nginx
  tags: ['config', 'vhosts']
```

---

## 🔴 Solution - tasks/main.yml (part 4)

```yaml
- name: Create web document roots
  file:
    path: "{{ item.root }}"
    state: directory
    owner: "{{ nginx_user }}"
    group: "{{ nginx_user }}"
    mode: '0755'
  loop: "{{ nginx_vhosts }}"
  when: nginx_vhosts | length > 0
  tags: ['config']

- name: Start and enable Nginx
  service:
    name: nginx
    state: "{{ nginx_service_state }}"
    enabled: "{{ nginx_service_enabled }}"
  tags: ['service']
```

---

## 🔴 Solution - handlers/main.yml

```yaml
# roles/nginx/handlers/main.yml
---
- name: Reload Nginx
  service:
    name: nginx
    state: reloaded

- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

---

## 🔴 Solution - meta/main.yml

```yaml
# roles/nginx/meta/main.yml
---
dependencies: []

galaxy_info:
  author: "Your Name"
  description: "Ansible role to install and configure Nginx"
  company: "Andromed"
  license: "MIT"
  min_ansible_version: 2.9
  
  platforms:
    - name: Ubuntu
      versions:
        - focal
        - jammy
  
  galaxy_tags:
    - nginx
    - webserver
    - web
```

---

## 🔴 Solution - templates/nginx.conf.j2

```nginx
# roles/nginx/templates/nginx.conf.j2
user {{ nginx_user }};
worker_processes {{ nginx_worker_processes }};
pid /run/nginx.pid;

events {
    worker_connections {{ nginx_worker_connections }};
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size {{ nginx_client_max_body_size }};

    include /etc/nginx/mime.types;
    default_type application/octet-stream;
```

---

## 🔴 Solution - nginx.conf.j2 (continued)

```nginx
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    # include every enabled site under sites-enabled
    include {{ nginx_vhost_enabled_path }}/*;
}
```

---

## 🔴 Solution - templates/vhost.conf.j2

```nginx
# roles/nginx/templates/vhost.conf.j2
server {
    listen {{ item.port | default(80) }};
    server_name {{ item.server_name }};

    root {{ item.root }};
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "OK - {{ item.server_name }}";
        add_header Content-Type text/plain;
    }
}
```

---

## 🔴 Testing the advanced exercise

```bash
# run the full playbook
ansible-playbook -i inventory.yml site.yml

# run selected tags only
ansible-playbook -i inventory.yml site.yml --tags "packages,config"

# validate nginx.conf syntax
ansible webservers -i inventory.yml -m shell -a "nginx -t"

# smoke-test vhosts
docker exec ansible-lab-web01 curl localhost
docker exec ansible-lab-web01 curl localhost/health

# list role tasks
ansible-playbook -i inventory.yml site.yml --list-tasks
```

**✅ Expected outcome**: a professional, reusable Nginx role!

---

## 🔴 Bonus: multi-environment production layout

### Ultimate mission: reproduce example 4

**Goal**: full production-style layout with staging and production

**Create this tree**:
```
production-project/
├── ansible.cfg
├── site.yml
├── inventories/
│   ├── staging/hosts.yml
│   └── production/hosts.yml
├── group_vars/
│   ├── all.yml
│   ├── staging.yml
│   └── production.yml
├── roles/
│   └── nginx/  (the role you built earlier)
└── secrets.yml (with Vault)
```

---

## 🔴 Bonus - ansible.cfg

```ini
# ansible.cfg
[defaults]
inventory = inventories/staging/hosts.yml
roles_path = ./roles
host_key_checking = False
retry_files_enabled = False
callback_whitelist = timer, profile_tasks
stdout_callback = yaml
log_path = ./ansible.log

[ssh_connection]
pipelining = True
```

---

## 🔴 Bonus - Inventories

```yaml
# inventories/staging/hosts.yml
all:
  vars:
    ansible_connection: docker
    ansible_user: root
    environment: staging
  
  children:
    webservers:
      hosts:
        web01:
          ansible_host: ansible-lab-web01
```

```yaml
# inventories/production/hosts.yml
all:
  vars:
    ansible_connection: docker
    ansible_user: root
    environment: production
  
  children:
    webservers:
      hosts:
        web01: {ansible_host: ansible-lab-web01}
        web02: {ansible_host: ansible-lab-web02}
        web03: {ansible_host: ansible-lab-web03}
```

---

## 🔴 Bonus - Per-environment variables

```yaml
# group_vars/staging.yml
---
app_environment: staging
nginx_worker_processes: 2
nginx_worker_connections: 512

nginx_vhosts:
  - server_name: staging.monapp.local
    root: /var/www/staging
    port: 80
```

```yaml
# group_vars/production.yml
---
app_environment: production
nginx_worker_processes: 4
nginx_worker_connections: 2048

nginx_vhosts:
  - server_name: www.monapp.com
    root: /var/www/production
    port: 80
```

---

## 🔴 Bonus - Using Ansible Vault

```bash
# create an encrypted vars file
ansible-vault create secrets.yml

# example secrets.yml content (plaintext before encrypt, or after decrypt)
vault_ssl_cert_password: "my_super_secret"
vault_admin_password: "secure_admin_password"

# run a playbook that loads vault files
ansible-playbook -i inventories/production site.yml --ask-vault-pass

# edit encrypted content
ansible-vault edit secrets.yml

# encrypt an existing file in place
ansible-vault encrypt secrets.yml
```

---

## 🔴 Testing the production-style project

```bash
# deploy staging
ansible-playbook -i inventories/staging site.yml

# deploy production
ansible-playbook -i inventories/production site.yml

# production with Vault password prompt
ansible-playbook -i inventories/production site.yml --ask-vault-pass

# dry-run before a real deploy
ansible-playbook -i inventories/production site.yml --check --diff

# deploy with tags
ansible-playbook -i inventories/production site.yml --tags "config"
```

---

## 📊 Exercise recap

### Skills you practiced

**🟢 Beginner track**:
- ✅ Build an Ansible inventory
- ✅ Write a basic playbook
- ✅ Use `apt` and `service`
- ✅ Deploy to one server

**🟡 Intermediate track**:
- ✅ Organize variables in `group_vars`
- ✅ Author Jinja2 templates
- ✅ Deploy to several servers
- ✅ Use handlers

---

## 📊 Exercise recap (continued)

**🔴 Advanced track**:
- ✅ Build a full Ansible role
- ✅ Professional layout (tasks, handlers, templates, defaults, meta)
- ✅ Defaults vs metadata
- ✅ Modular templates
- ✅ Tags for selective runs

**🔴 Production bonus**:
- ✅ Multi-environment (staging / prod)
- ✅ Central config (`ansible.cfg`)
- ✅ Ansible Vault for secrets
- ✅ Project structure that scales

---

## 🎯 Mapping: examples vs exercises

### You reproduced every sample path!

| Example | Exercise | Concepts |
|---------|----------|----------|
| 01-simple-playbook | 🟢 Beginner | Core playbook |
| 02-variables-templates | 🟡 Intermediate | Variables + templates |
| 03-avec-roles | 🔴 Advanced | Roles |
| 04-projet-production | 🔴 Bonus | Multi-env + Vault |

**💪 Well done!** You now have end-to-end Ansible practice under your belt.

---

## 💡 Key takeaways

### Foundations

✅ **Inventory**: the hosts Ansible manages  
✅ **Playbook**: ordered tasks for those hosts  
✅ **Variables**: tune deployments without editing tasks  
✅ **Templates**: render dynamic config files  
✅ **Handlers**: react to changes (restart/reload)  
✅ **Roles**: reusable, modular layout  
✅ **Tags**: run slices of a playbook  
✅ **Vault**: encrypt secrets at rest  

---

## 🚀 Go further

### Next steps

**Harden your roles**:
- Add Molecule tests
- Publish to Ansible Galaxy
- Add TLS termination
- Automate Let's Encrypt certificates

**Wire into CI/CD**:
- GitHub Actions + Ansible
- GitLab CI + Ansible
- Jenkins + Ansible

**Explore**:
- AWX / Ansible Automation Platform
- Ansible Operator on Kubernetes
- Cloud collections (AWS, Azure, GCP)

---

## 🎉 Congratulations!

### You finished the Ansible exercise track!

You can now:
- 📋 Maintain inventories of real servers
- 🎭 Author effective playbooks
- 🔧 Combine variables and templates
- 📦 Ship reusable roles
- 🔐 Protect secrets with Vault
- 🚀 Structure production-grade projects

**Ready for the final quiz?** ✅
