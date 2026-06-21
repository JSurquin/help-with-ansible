---
layout: new-section
routeAlias: 'cheatsheet-tasks'
---

<a name="cheatsheet-tasks" id="cheatsheet-tasks"></a>

# Cheat sheet — common playbook tasks

---

# Ansible cheat sheet: intro 📚

### Essential modules by category

This section lists core modules you use most in playbooks.

**Categories**:
- 📦 packages
- ⚙️ services
- 📁 files and directories
- 👥 users and permissions
- 🐳 Docker
- 💻 commands
- 🌐 networking
- 🗄️ databases
- 🔧 variables and debug
- 📝 Git and version control

---
layout: new-section
---

# 📦 Packages

---

# Packages: apt (Debian/Ubuntu)

### Package installs on Debian/Ubuntu

```yaml
# single package
- name: Install nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

# several packages
- name: Install common packages
  apt:
    name:
      - nginx
      - git
      - curl
      - vim
    state: present
    update_cache: yes
```

---

# Packages: apt (continued)

```yaml
# upgrade one package
- name: Upgrade nginx to latest
  apt:
    name: nginx
    state: latest

# remove package
- name: Remove nginx
  apt:
    name: nginx
    state: absent

# full distro upgrade
- name: Dist-upgrade all packages
  apt:
    upgrade: dist
    update_cache: yes
```

---

# Packages: yum (RHEL/CentOS)

### Package installs on RHEL/CentOS

```yaml
# one package
- name: Install httpd
  yum:
    name: httpd
    state: present

# several packages
- name: Install base packages
  yum:
    name:
      - httpd
      - git
      - python3
    state: present
```

---

# Packages: yum (continued)

```yaml
# upgrade one package
- name: Upgrade httpd
  yum:
    name: httpd
    state: latest

# remove package
- name: Remove httpd
  yum:
    name: httpd
    state: absent

# install from RPM file
- name: Install from RPM file
  yum:
    name: /tmp/package.rpm
    state: present
```

---

# Packages: dnf (Fedora/RHEL 8+)

### Modern `dnf` installs

```yaml
# one package
- name: Install nginx with dnf
  dnf:
    name: nginx
    state: present

# several packages
- name: Install several packages
  dnf:
    name:
      - nginx
      - podman
      - python3-pip
    state: present
```

---

# Packages: pip (Python)

### Python packages

```yaml
# global pip install
- name: Install Ansible via pip
  pip:
    name: ansible
    state: present

# into a virtualenv
- name: Install into venv
  pip:
    name: flask
    virtualenv: /opt/myapp/venv
    virtualenv_python: python3

# from requirements.txt
- name: Install from requirements file
  pip:
    requirements: /opt/myapp/requirements.txt
    virtualenv: /opt/myapp/venv
```

---

# Packages: npm (Node.js)

### Node packages

```yaml
# global npm package
- name: Install global npm package
  npm:
    name: pm2
    global: yes

# project dependencies
- name: Install project dependencies
  npm:
    path: /opt/webapp
    state: present

# pin a version
- name: Install specific version
  npm:
    name: vue
    version: '3.2.45'
```

---
layout: new-section
---

# ⚙️ Services

---

# Services: systemd (modern)

### Manage units with systemd

⚠️ **`systemd` does not work inside most Docker containers** — use the `service` module there.

This section targets **VMs and bare metal** only.

```yaml
# start service
- name: Start nginx
  systemd:
    name: nginx
    state: started

# stop service
- name: Stop nginx
  systemd:
    name: nginx
    state: stopped

# restart service
- name: Restart nginx
  systemd:
    name: nginx
    state: restarted
```

---

# Services: systemd (continued)

```yaml
# reload unit config
- name: Reload nginx
  systemd:
    name: nginx
    state: reloaded

# enable at boot
- name: Enable nginx at boot
  systemd:
    name: nginx
    enabled: yes

# disable at boot
- name: Disable nginx at boot
  systemd:
    name: nginx
    enabled: no
```

---

# Services: systemd (advanced)

### Advanced options (VMs/servers only)

⚠️ **Reminder**: not available the same way in Docker

```yaml
# reload systemd manager configuration
- name: Reload systemd daemon
  systemd:
    daemon_reload: yes

# start and enable together
- name: Start and enable docker
  systemd:
    name: docker
    state: started
    enabled: yes

# query service state
- name: Check nginx status
  systemd:
    name: nginx
  register: nginx_status
```

💡 **For Docker**: use `service` (next slide)

---

# Services: `service` (recommended in Docker)

### Generic init compatibility

💡 **`service` works in Docker containers**; `systemd` often does not.

```yaml
# start service
- name: Start nginx
  service:
    name: nginx
    state: started

# restart service
- name: Restart apache2
  service:
    name: apache2
    state: restarted

# enable at boot
- name: Enable mysql
  service:
    name: mysql
    enabled: yes
```

---

# Services: systemd (VMs and physical servers)

### systemd unit management

⚠️ **Note**: `systemd` is **not** for typical Docker containers — use `service`.

```yaml
# start (on VM / physical host)
- name: Start nginx
  systemd:
    name: nginx
    state: started

# stop
- name: Stop nginx
  systemd:
    name: nginx
    state: stopped

# restart
- name: Restart nginx
  systemd:
    name: nginx
    state: restarted
```

```yaml
# remove a file
- name: Remove temp file
  file:
    path: /tmp/old-file.txt
    state: absent

# remove directory tree
- name: Remove old app directory
  file:
    path: /opt/old-app
    state: absent

# symlink
- name: Create symlink
  file:
    src: /opt/app/current
    dest: /var/www/app
    state: link
```

---

# Files: copy (simple)

### Push files to hosts

```yaml
# local → remote
- name: Copy app config
  copy:
    src: files/app.conf
    dest: /etc/app/app.conf
    owner: root
    group: root
    mode: '0644'

# inline content
- name: Create file from inline content
  copy:
    content: |
      APP_NAME=myapp
      APP_ENV=production
    dest: /opt/app/.env
    mode: '0600'
```

---

# Files: copy (backup / remote)

```yaml
# keep backup of previous file
- name: Copy with backup
  copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf
    backup: yes

# remote → remote
- name: Copy between remote paths
  copy:
    src: /tmp/file.txt
    dest: /opt/app/file.txt
    remote_src: yes

# validate after copy
- name: Copy with validation
  copy:
    src: files/config.json
    dest: /etc/app/config.json
    validate: 'json_verify %s'
```

---

# Files: template (Jinja2)

### Render dynamic files

```yaml
# simple template
- name: Deploy nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
  notify: restart nginx

# template with variables
- name: Create .env file
  template:
    src: dotenv.j2
    dest: /opt/app/.env
    mode: '0600'
```

---

# Files: template (advanced)

```yaml
# template with backup
- name: Template with backup
  template:
    src: app.conf.j2
    dest: /etc/app/app.conf
    backup: yes

# template with validation
- name: Validated nginx template
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    validate: 'nginx -t -c %s'
  notify: reload nginx
```

---

# Files: fetch (pull from hosts)

### Pull files back to the controller

```yaml
# single file
- name: Fetch logs
  fetch:
    src: /var/log/app/error.log
    dest: ./logs/{{ inventory_hostname }}/
    flat: yes

# preserve layout under dest
- name: Fetch config
  fetch:
    src: /etc/app/app.conf
    dest: ./backups/

# verify checksum
- name: Fetch with checksum
  fetch:
    src: /opt/app/data.db
    dest: ./backups/
    validate_checksum: yes
```

---

# Files: lineinfile (line edits)

### Edit specific lines

```yaml
# append line
- name: Add hosts entry
  lineinfile:
    path: /etc/hosts
    line: '192.168.1.10 myserver.local'

# replace by regex
- name: Change setting
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^PermitRootLogin'
    line: 'PermitRootLogin no'

# remove line
- name: Remove line
  lineinfile:
    path: /etc/hosts
    regexp: '^192.168.1.10'
    state: absent
```

---

# Files: blockinfile (block edits)

### Insert or replace marked blocks

```yaml
# insert block
- name: Add Apache snippet
  blockinfile:
    path: /etc/apache2/apache2.conf
    block: |
      <VirtualHost *:80>
        ServerName example.com
        DocumentRoot /var/www/html
      </VirtualHost>

# replace managed block
- name: Replace managed block
  blockinfile:
    path: /etc/config.conf
    marker: "# {mark} MANAGED BLOCK"
    block: |
      option1=value1
      option2=value2
```

---

# Files: synchronize (rsync)

### Sync directories

```yaml
# local → remote
- name: Sync application tree
  synchronize:
    src: /local/app/
    dest: /opt/app/
    delete: yes
    recursive: yes

# with excludes
- name: Sync with excludes
  synchronize:
    src: ./build/
    dest: /var/www/html/
    rsync_opts:
      - "--exclude=.git"
      - "--exclude=node_modules"
```

---
layout: new-section
---

# 👥 Users and permissions

---

# Users: user

### System accounts

```yaml
# create user
- name: Create deploy user
  user:
    name: deploy
    shell: /bin/bash
    create_home: yes
    home: /home/deploy

# user with supplementary groups
- name: Create user with groups
  user:
    name: webapp
    groups: www-data,docker
    append: yes
    shell: /bin/bash
```

---

# Users: user (continued)

```yaml
# add SSH key (authorized_key is separate module in real playbooks)
- name: Add SSH key
  user:
    name: deploy
    state: present
  authorized_key:
    user: deploy
    key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"

# remove user
- name: Remove user
  user:
    name: olduser
    state: absent
    remove: yes

# set password hash
- name: Set password hash
  user:
    name: deploy
    password: "{{ 'mypassword' | password_hash('sha512') }}"
```

---

# Groups: group

### System groups

```yaml
# create group
- name: Create docker group
  group:
    name: docker
    state: present

# fixed GID
- name: Create group with GID
  group:
    name: webapp
    gid: 1001
    state: present

# remove group
- name: Remove group
  group:
    name: oldgroup
    state: absent
```

---

# Permissions: acl

### POSIX ACLs

```yaml
# user ACL
- name: User ACL on app dir
  acl:
    path: /opt/app
    entity: webapp
    etype: user
    permissions: rwx
    state: present

# default ACL on directory
- name: Default group ACL
  acl:
    path: /opt/shared
    entity: developers
    etype: group
    permissions: rw
    default: yes
    state: present
```

---

# SSH: authorized_key

### Authorized keys

```yaml
# add one key
- name: Add public key
  authorized_key:
    user: ubuntu
    key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
    state: present

# several keys
- name: Add multiple keys
  authorized_key:
    user: deploy
    key: "{{ item }}"
  loop:
    - "ssh-rsa AAAAB3...key1"
    - "ssh-rsa AAAAB3...key2"

# remove key
- name: Remove key
  authorized_key:
    user: ubuntu
    key: "ssh-rsa AAAAB3...oldkey"
    state: absent
```

---
layout: new-section
---

# 🐳 Docker

---

# Docker: docker_container

### Run containers

```yaml
# simple container
- name: Run nginx
  community.docker.docker_container:
    name: nginx
    image: nginx:alpine
    state: started
    ports:
      - "80:80"

# with environment
- name: Run application container
  community.docker.docker_container:
    name: webapp
    image: myapp:latest
    state: started
    env:
      APP_ENV: production
      DB_HOST: db.example.com
```

---

# Docker: docker_container (volumes)

```yaml
# bind mounts
- name: Container with volumes
  community.docker.docker_container:
    name: database
    image: postgres:15
    state: started
    volumes:
      - /opt/postgres/data:/var/lib/postgresql/data
      - /opt/postgres/backup:/backup
    env:
      POSTGRES_PASSWORD: "{{ vault_db_password }}"

# restart policy
- name: Container with restart policy
  community.docker.docker_container:
    name: app
    image: myapp:v1.0
    state: started
    restart_policy: always
```

---

# Docker: docker_container (network)

```yaml
# custom network
- name: Container on custom network
  community.docker.docker_container:
    name: webapp
    image: nginx
    networks:
      - name: frontend
    state: started

# stop
- name: Stop container
  community.docker.docker_container:
    name: webapp
    state: stopped

# remove
- name: Remove container
  community.docker.docker_container:
    name: old-app
    state: absent
```

---

# Docker: docker_image

### Images

```yaml
# pull
- name: Pull image
  community.docker.docker_image:
    name: nginx:alpine
    source: pull

# build
- name: Build custom image
  community.docker.docker_image:
    name: myapp:latest
    build:
      path: /opt/myapp
      dockerfile: Dockerfile
    source: build

# remove image
- name: Remove image
  community.docker.docker_image:
    name: old-app:v1.0
    state: absent
```

---

# Docker: docker_network

### Networks

```yaml
# create network
- name: Create frontend network
  community.docker.docker_network:
    name: frontend
    driver: bridge
    state: present

# network with subnet
- name: Network with custom subnet
  community.docker.docker_network:
    name: backend
    ipam_config:
      - subnet: 172.20.0.0/16
        gateway: 172.20.0.1

# remove network
- name: Remove network
  community.docker.docker_network:
    name: old-network
    state: absent
```

---

# Docker: docker_volume

### Named volumes

```yaml
# create volume
- name: Create data volume
  community.docker.docker_volume:
    name: app-data
    state: present

# volume with driver options
- name: Volume with driver options
  community.docker.docker_volume:
    name: backup-data
    driver: local
    driver_options:
      type: nfs
      o: addr=nfs-server,rw
      device: ":/path/to/data"

# remove volume
- name: Remove volume
  community.docker.docker_volume:
    name: old-data
    state: absent
```

---

# Docker: docker_compose

### Compose stacks

```yaml
# start compose project
- name: Start compose services
  community.docker.docker_compose:
    project_src: /opt/myapp
    state: present

# tear down
- name: Stop compose stack
  community.docker.docker_compose:
    project_src: /opt/myapp
    state: absent

# rebuild + restart
- name: Rebuild services
  community.docker.docker_compose:
    project_src: /opt/myapp
    build: yes
    restarted: yes
```

---

# Docker: docker_login

### Registry auth

```yaml
# Docker Hub
- name: Login Docker Hub
  community.docker.docker_login:
    username: myuser
    password: "{{ vault_docker_password }}"

# private registry
- name: Login private registry
  community.docker.docker_login:
    registry_url: registry.example.com
    username: deployer
    password: "{{ vault_registry_password }}"

# logout
- name: Logout
  community.docker.docker_login:
    state: absent
```

---

# Docker: docker_prune

### Cleanup

```yaml
# stopped containers
- name: Prune containers
  community.docker.docker_prune:
    containers: yes

# unused images
- name: Prune images
  community.docker.docker_prune:
    images: yes
    images_filters:
      dangling: false

# aggressive cleanup
- name: Full prune
  community.docker.docker_prune:
    containers: yes
    images: yes
    networks: yes
    volumes: yes
    builder_cache: yes
```

---
layout: new-section
---

# 💻 Commands

---

# Commands: command

### Non-shell commands (no pipes)

```yaml
# simple command
- name: Create directory
  command: mkdir -p /opt/app/data

# with args
- name: List files
  command: ls -la /opt/app
  register: listing

# working directory
- name: Build application
  command: make build
  args:
    chdir: /opt/app

# skip if marker file exists
- name: Initialize database
  command: ./init-db.sh
  args:
    creates: /opt/app/db.sqlite
```

---

# Commands: shell

### Full shell (pipes, redirects)

```yaml
# pipes / redirects
- name: Backup database
  shell: |
    mysqldump -u root -p{{ db_password }} mydb > /backup/db.sql
  no_log: yes

# environment
- name: Command with env vars
  shell: npm install
  args:
    chdir: /opt/webapp
  environment:
    NODE_ENV: production

# probe without failing play
- name: Check Node version
  shell: node --version | grep "v18"
  register: node_version
  changed_when: false
  failed_when: false
```

---

# Commands: script

### Copy local script, run on remote

```yaml
# bash script from files/
- name: Run setup script
  script: scripts/setup.sh

# with arguments
- name: Script with args
  script: scripts/deploy.sh --env production --version 1.2.0

# python script
- name: Run Python script
  script: scripts/migration.py
  args:
    executable: python3
```

---

# Commands: raw

### No Python on target yet

```yaml
# bootstrap python
- name: Install Python
  raw: apt-get install -y python3

# minimal reboot
- name: Reboot server
  raw: shutdown -r now
  async: 0
  poll: 0

# quick check
- name: Check uptime
  raw: uptime
  register: uptime_result
```

---

# Commands: expect

### Drive interactive CLIs

```yaml
# scripted answers
- name: Harden MySQL install
  expect:
    command: mysql_secure_installation
    responses:
      'Enter password': "{{ mysql_root_password }}"
      'New password': "{{ new_mysql_password }}"
      'Remove anonymous users': 'Y'
      'Disallow root login remotely': 'Y'
```

---
layout: new-section
---

# 🌐 Network and HTTP APIs

---

# Network: uri (HTTP)

### Call HTTP APIs

```yaml
# simple GET
- name: Check API health
  uri:
    url: https://api.example.com/health
    method: GET
    status_code: 200

# POST JSON
- name: Create user via API
  uri:
    url: https://api.example.com/users
    method: POST
    body_format: json
    body:
      name: John Doe
      email: john@example.com
    headers:
      Authorization: "Bearer {{ api_token }}"
    status_code: 201
```

---

# Network: uri (continued)

```yaml
# PUT update
- name: Update resource
  uri:
    url: https://api.example.com/resource/123
    method: PUT
    body_format: json
    body:
      status: active
    return_content: yes
  register: api_response

# DELETE
- name: Delete resource
  uri:
    url: https://api.example.com/resource/456
    method: DELETE
    status_code: 204
```

---

# Network: get_url

### Download files

```yaml
# download archive
- name: Download binary archive
  get_url:
    url: https://example.com/app.tar.gz
    dest: /tmp/app.tar.gz
    mode: '0644'

# checksum verify
- name: Download with checksum
  get_url:
    url: https://example.com/file.zip
    dest: /opt/file.zip
    checksum: sha256:abc123...

# basic auth
- name: Download protected file
  get_url:
    url: https://secure.example.com/data.json
    dest: /opt/data.json
    url_username: user
    url_password: "{{ vault_password }}"
```

---

# Network: wait_for

### Wait for port/path

```yaml
# wait for DB port
- name: Wait for MySQL
  wait_for:
    host: db.example.com
    port: 3306
    delay: 5
    timeout: 300

# wait until port closed
- name: Wait for nginx to stop
  wait_for:
    port: 80
    state: stopped
    timeout: 60

# wait for file
- name: Wait for ready file
  wait_for:
    path: /opt/app/ready.flag
    state: present
```

---

# Network: wait_for_connection

### Wait for SSH after boot

```yaml
# host back online
- name: Wait for SSH
  wait_for_connection:
    delay: 10
    timeout: 300

# typical reboot flow
- name: Reboot and wait
  reboot:
  
- name: Wait for reconnect
  wait_for_connection:
    delay: 30
```

---
layout: new-section
---

# 🗄️ Databases

---

# MySQL: mysql_db

### MySQL databases

```yaml
# create database
- name: Create MySQL database
  mysql_db:
    name: myapp
    state: present
    login_user: root
    login_password: "{{ vault_mysql_root }}"

# drop database
- name: Drop database
  mysql_db:
    name: oldapp
    state: absent

# import SQL dump
- name: Import SQL dump
  mysql_db:
    name: myapp
    state: import
    target: /tmp/backup.sql
```

---

# MySQL: mysql_user

### MySQL users

```yaml
# app user
- name: Create application DB user
  mysql_user:
    name: webapp
    password: "{{ vault_mysql_password }}"
    priv: 'myapp.*:ALL'
    state: present
    login_user: root
    login_password: "{{ vault_mysql_root }}"

# limited privileges
- name: Read-only user
  mysql_user:
    name: readonly
    password: "{{ vault_readonly_password }}"
    priv: 'myapp.*:SELECT'
    host: '192.168.1.%'
```

---

# MySQL: mysql_user (continued)

```yaml
# drop user
- name: Drop MySQL user
  mysql_user:
    name: olduser
    state: absent

# rotate password
- name: Rotate password
  mysql_user:
    name: webapp
    password: "{{ new_password }}"
    update_password: always
```

---

# PostgreSQL: postgresql_db

### PostgreSQL databases

```yaml
# create DB
- name: Create database
  postgresql_db:
    name: myapp
    owner: webapp
    state: present
  become_user: postgres

# specific locale (example uses en_US.UTF-8 — pick yours)
- name: Database with UTF-8 locale
  postgresql_db:
    name: myapp_prod
    encoding: UTF-8
    lc_collate: en_US.UTF-8
    lc_ctype: en_US.UTF-8
    template: template0

# drop DB
- name: Drop database
  postgresql_db:
    name: oldapp
    state: absent
```

---

# PostgreSQL: postgresql_user

### PostgreSQL roles

```yaml
# create role
- name: Create PostgreSQL user
  postgresql_user:
    name: webapp
    password: "{{ vault_pg_password }}"
    role_attr_flags: CREATEDB,NOSUPERUSER
  become_user: postgres

# grant on database
- name: Grant privileges
  postgresql_privs:
    database: myapp
    roles: webapp
    privs: ALL
    type: database
  become_user: postgres

# drop role
- name: Drop user
  postgresql_user:
    name: olduser
    state: absent
```

---

# Redis: community.general.redis

### Redis key/value

```yaml
# set key
- name: Set Redis key
  community.general.redis:
    command: set
    login_host: localhost
    key: myapp:config
    value: '{"env":"production"}'

# get value
- name: Get Redis value
  community.general.redis:
    command: get
    key: myapp:status
  register: redis_value

# delete key
- name: Delete key
  community.general.redis:
    command: delete
    key: old:data
```

---
layout: new-section
---

# 🔧 Variables and debug

---

# Variables: set_fact

### Define variables at runtime

**set_fact** creates or updates a variable **while** the play runs.

**⚠️ Golden rule**: do not stack every `set_fact` at the top “by default”.

**🎯 Principle**: place it **right before** you actually need it.

---

# set_fact: when to use it

### Three main cases

**1. Dynamic values (depend on runtime)**

```yaml
- name: Compute backup date
  set_fact:
    backup_date: "{{ ansible_date_time.date }}"
```

**2. Data shaping**

```yaml
- name: Read Node version string
  shell: node --version
  register: result

- name: Strip leading v
  set_fact:
    node_ver: "{{ result.stdout | regex_replace('^v', '') }}"
```

---

# set_fact: when to use it (continued)

**3. Runtime conditions**

```yaml
- name: Decide prod mode
  set_fact:
    is_prod: "{{ env == 'prod' }}"

- name: Production config template
  template:
    src: app.conf.j2
    dest: /etc/app.conf
  when: is_prod
```

**❌ Not for static literals** → use `vars:` instead.

---

# set_fact vs vars: pick the right tool

### Practical comparison

**If you can write it without `{{ }}` → skip set_fact**

```yaml
# ❌ bad: set_fact for a constant
- set_fact:
    app_path: "/var/www/app"

# ✅ good: vars for a constant
vars:
  app_path: "/var/www/app"
```

---

# set_fact vs vars (continued)

**If it depends on a previous result → set_fact**

```yaml
# ✅ good: derived from stat
- name: Check if config exists
  stat:
    path: /etc/app.conf
  register: config_file

- name: First install?
  set_fact:
    first_install: "{{ not config_file.stat.exists }}"

- name: Seed default config
  template:
    src: default.conf.j2
    dest: /etc/app.conf
  when: first_install
```

---

# Where to put set_fact: simple case

### Most common: right before use

```yaml
- hosts: all
  tasks:
    - name: Set app path
      set_fact:
        app_path: "/var/www/app"

    - name: Create directory
      file:
        path: "{{ app_path }}"
        state: directory

    - name: Copy file
      copy:
        src: app.js
        dest: "{{ app_path }}/app.js"
```

**👉 Safe to reuse `app_path` in later tasks in the same play**

---

# Where to put set_fact: good practice

### Immediately next to consumers

```yaml
- hosts: all
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Compute vhost path
      set_fact:
        config_path: "/etc/nginx/sites-available/{{ app_name }}.conf"

    - name: Deploy nginx config
      template:
        src: nginx.conf.j2
        dest: "{{ config_path }}"
```

**💡 Easier to read: you see where the value is used**

---

# Where to put set_fact: anti-pattern

### ❌ “Wall of facts” at the top

```yaml
- hosts: all
  tasks:
    - set_fact:
        a: 1
        b: 2
        c: 3
        d: 4
        e: 5
        f: 6
    
    # ... 50 tasks later ...
    
    - debug:
        msg: "{{ f }}"
```

**Why it hurts**:
- 🚫 hidden dependencies
- 🚫 harder debugging
- 🚫 painful maintenance

---

# Concrete example: dynamic branch

### Typical set_fact use

```yaml
- hosts: webservers
  vars:
    env: "prod"
  
  tasks:
    - name: Set is_prod flag
      set_fact:
        is_prod: "{{ env == 'prod' }}"

    - name: Production security template
      template:
        src: secure.conf.j2
        dest: /etc/app/security.conf
      when: is_prod

    - name: Enable debug outside prod
      lineinfile:
        path: /etc/app/app.conf
        line: "DEBUG=true"
      when: not is_prod
```

---

# Concrete example: parse command output

### Clean registered stdout

```yaml
- hosts: all
  tasks:
    - name: Read docker version string
      shell: docker --version
      register: docker_output

    - name: Extract semver
      set_fact:
        docker_version: "{{ docker_output.stdout | regex_search('([0-9]+\\.[0-9]+\\.[0-9]+)') }}"

    - name: Enforce minimum version
      fail:
        msg: "Docker {{ docker_version }} too old (>= 24.0.0 required)"
      when: docker_version is version('24.0.0', '<')

    - name: Run app container
      docker_container:
        name: myapp
        image: "myapp:latest"
```

---

# Concrete example: build a dict

### Assemble structured data

```yaml
- hosts: all
  vars:
    app_name: "myapp"
    app_version: "1.2.3"
    environment: "prod"
  
  tasks:
    - name: Build config object
      set_fact:
        app_config:
          name: "{{ app_name }}"
          version: "{{ app_version }}"
          env: "{{ environment }}"
          deploy_time: "{{ ansible_date_time.iso8601 }}"
          server: "{{ ansible_facts['hostname'] }}"
          ip: "{{ ansible_facts['default_ipv4']['address'] }}"

    - name: Write JSON config
      copy:
        content: "{{ app_config | to_nice_json }}"
        dest: "/etc/{{ app_name }}/config.json"
```

---

# set_fact: scope

### Where does the variable exist?

**set_fact** is **host-scoped** (not global)

```yaml
- hosts: web1
  tasks:
    - set_fact:
        my_var: "hello"
    
    - debug:
        msg: "{{ my_var }}"  # ✅ works

- hosts: web2
  tasks:
    - debug:
        msg: "{{ my_var }}"  # ❌ undefined on web2
```

---

# set_fact: sharing across hosts

### Broadcast a computed value

**Pattern 1: `run_once` + `delegate_to`**

```yaml
- hosts: all
  tasks:
    - name: Shared deploy timestamp
      set_fact:
        deploy_timestamp: "{{ ansible_date_time.epoch }}"
      run_once: true
      delegate_to: localhost
      delegate_facts: true

    - name: Read from controller hostvars
      debug:
        msg: "Deployed at: {{ hostvars['localhost']['deploy_timestamp'] }}"
```

---

# set_fact: sharing (continued)

**Pattern 2: loop all hosts**

```yaml
- hosts: localhost
  gather_facts: yes
  tasks:
    - name: Stamp version on every host
      set_fact:
        app_version: "1.2.3"
      delegate_to: "{{ item }}"
      delegate_facts: true
      with_items: "{{ groups['all'] }}"

- hosts: all
  tasks:
    - debug:
        msg: "Version: {{ app_version }}"
```

---

# set_fact “globals”: pattern 3 (usually best)

### Prefer `group_vars` for true globals

**⚠️ If the value is static, use `group_vars/all.yml` (or `all/`).**

```yaml
# group_vars/all.yml
app_version: "1.2.3"
deploy_user: "ansible"
base_path: "/opt/apps"
```

**Why it wins**:
- ✅ simpler to read
- ✅ no `delegate_facts`
- ✅ best performance
- ✅ available everywhere automatically

**🎯 Rule**: cross-host `set_fact` only when you must compute at runtime

---

# set_fact with `register`

### Chain shell output → facts

```yaml
- hosts: databases
  tasks:
    - name: Count MySQL connections
      shell: mysql -e "SHOW PROCESSLIST" | wc -l
      register: mysql_connections

    - name: Derive usage metrics
      set_fact:
        max_connections: 100
        current_usage: "{{ mysql_connections.stdout | int }}"
        usage_percent: "{{ (mysql_connections.stdout | int / 100 * 100) | round(2) }}"

    - name: Warn if hot
      debug:
        msg: "⚠️ ALERT: {{ usage_percent }}% connection budget used"
      when: usage_percent | float > 80
```

---

# set_fact: advanced everyday snippets

### Real patterns

**1. Detect package manager family**

```yaml
- name: Detect package manager family
  set_fact:
    pkg_manager: "{{ 'apt' if ansible_facts['os_family'] == 'Debian' else 'yum' }}"

- name: Install nginx
  package:
    name: nginx
    state: present
  vars:
    ansible_pkg_mgr: "{{ pkg_manager }}"
```

---

# set_fact: advanced snippets (continued)

**2. Build a dynamic URL**

```yaml
- name: Protocol and port from env
  set_fact:
    use_ssl: "{{ env == 'prod' }}"
    protocol: "{{ 'https' if env == 'prod' else 'http' }}"
    port: "{{ 443 if env == 'prod' else 80 }}"

- name: Compose API base URL
  set_fact:
    api_url: "{{ protocol }}://api.{{ domain }}:{{ port }}/v1"

- name: Render app config
  template:
    src: app.conf.j2
    dest: /etc/app.conf
  vars:
    api_endpoint: "{{ api_url }}"
```

---

# set_fact: advanced snippets (continued 2)

**3. Merge lists conditionally**

```yaml
- hosts: webservers
  vars:
    base_packages:
      - nginx
      - curl
      - git
    prod_packages:
      - monitoring-agent
      - security-tools
  
  tasks:
    - name: Build package list
      set_fact:
        all_packages: "{{ base_packages + (prod_packages if env == 'prod' else []) }}"

    - name: Install packages
      apt:
        name: "{{ all_packages }}"
        state: present
```

---

# set_fact vs vars vs defaults: recap

### Which tool when?

| Situation | Tool | Example |
|-----------|------|---------|
| Static literal | play `vars:` | `app_name: "myapp"` |
| Tunable default | `defaults/main.yml` | `nginx_port: 80` |
| System constant | `vars/main.yml` | `nginx_service: nginx` |
| Runtime math | `set_fact` | `timestamp: "{{ ansible_date_time.date }}"` |
| Runtime branch | `set_fact` | `is_prod: "{{ env == 'prod' }}"` |
| Parse `register` | `set_fact` | `version: "{{ result.stdout \| regex }}"` |

---

# Summary: set_fact golden rules

### Takeaways

**✅ Use set_fact for**:
- dynamic values (timestamps, host-derived strings…)
- runtime branches (`is_prod`, `should_backup`…)
- shaping `register` results

**❌ Avoid set_fact for**:
- static literals → `vars:`
- role defaults → `defaults/main.yml`
- constants → `vars/main.yml`

**📍 Placement**:
- immediately before consumers
- after the task that supplies inputs

**🎯 One-liner**: `set_fact` = runtime computation, not static storage

---

# 💡 Cheat sheet: vars, facts, set_fact

### Which approach fits?

```yaml
# 1. STATIC VALUES
vars:
  app_name: "myapp"          # ✅ clear
  app_port: 8080

# 2. FACTS (auto-gathered)
- debug:
    msg: "{{ ansible_facts['hostname'] }}"  # ✅ discovered for you

# 3. SET_FACT (runtime)
- set_fact:
    is_prod: "{{ env == 'prod' }}"  # ✅ dynamic branch
    
- set_fact:
    deploy_time: "{{ ansible_date_time.iso8601 }}"  # ✅ timestamp
```

---

# Checklist: before using set_fact

### Ask yourself

**1. Is it static?**
- ✅ yes → `vars:` or `defaults/`
- ❌ no → continue

**2. Does it depend on a command/register?**
- ✅ yes → `set_fact` fits
- ❌ no → prefer `vars:`

**3. Where does it live?**
- ✅ right before use
- ❌ not a giant block at play start

**4. Can you write it without `{{ }}`?**
- ✅ yes → `vars:` (static)
- ❌ no → `set_fact` (dynamic)

---

# Decision tree: how to store a value

### Which mechanism?

```
Need a value?
│
├─ System fact? (OS, CPU, RAM…)
│  └─ ✅ ansible_facts['...']
│
├─ Known ahead of time and fixed?
│  ├─ User-tunable default?
│  │  └─ ✅ role defaults/main.yml
│  │
│  ├─ System constant (paths, service names)?
│  │  └─ ✅ role vars/main.yml
│  │
│  └─ Simple play variable?
│     └─ ✅ play vars: or group_vars/
│
└─ Depends on command/register/branching?
   └─ ✅ set_fact (right before use)
```

---

# ❌ Common mistakes vs ✅ good habits

### Mistake 1: set_fact for a static path

```yaml
# ❌ BAD
- name: Set path
  set_fact:
    app_path: "/var/www/app"

# ✅ GOOD
vars:
  app_path: "/var/www/app"
```

**Why**: static values belong in `vars:`.

---

# ❌ Common mistakes vs ✅ good habits (2)

### Mistake 2: wall of facts at the top

```yaml
# ❌ BAD: define everything up front
- hosts: all
  tasks:
    - set_fact:
        var_a: "value_a"
        var_b: "value_b"
        var_c: "value_c"
    
    - name: Task 1
      debug: msg="Task 1"
    
    # ... 50 tasks later ...
    
    - name: Use var_c
      debug: msg="{{ var_c }}"
```

---

# ❌ Common mistakes vs ✅ good habits (3)

### Fix: compute near use

```yaml
# ✅ GOOD: just before use
- hosts: all
  tasks:
    - name: Task 1
      debug: msg="Task 1"
    
    # ... other tasks ...
    
    - name: Compute value for next task
      set_fact:
        var_c: "{{ some_calculation }}"
    
    - name: Use var_c
      debug: msg="{{ var_c }}"
```

**Why**: clearer dependencies.

---

# ❌ Common mistakes vs ✅ good habits (4)

### Mistake 3: ignoring facts

```yaml
# ❌ BAD: shell out for hostname
- name: Get hostname
  command: hostname
  register: host_result

- set_fact:
    server_name: "{{ host_result.stdout }}"

# ✅ GOOD: use facts
- debug:
    msg: "Server: {{ ansible_facts['hostname'] }}"
```

**Why**: facts are already collected.

---

# ❌ Common mistakes vs ✅ good habits (5)

### Mistake 4: delegate_facts for a static version

```yaml
# ❌ BAD: overcomplicated
- hosts: localhost
  tasks:
    - set_fact:
        app_version: "1.2.3"
      delegate_to: "{{ item }}"
      delegate_facts: true
      with_items: "{{ groups['all'] }}"
```

```yaml
# ✅ GOOD: group_vars/all.yml
app_version: "1.2.3"
```

**Why**: static globals → `group_vars`.

---

# 📚 Everyday examples: what to use

### Real cases

**Case 1: app port**

```yaml
# known per environment
# ✅ group_vars/production.yml
app_port: 443

# ✅ group_vars/dev.yml
app_port: 8080
```

---

# 📚 Everyday examples (2)

### Real cases

**Case 2: system service names**

```yaml
# OS/package constants
# ✅ roles/nginx/vars/main.yml
nginx_service: nginx
nginx_package: nginx
nginx_config_path: /etc/nginx/nginx.conf
```

---

# 📚 Everyday examples (3)

### Real cases

**Case 3: server hostname**

```yaml
# already in facts
# ✅ use facts
- name: Show hostname
  debug:
    msg: "Host {{ ansible_facts['hostname'] }}"

# ❌ do not do this
- command: hostname
  register: result
- set_fact:
    hostname: "{{ result.stdout }}"
```

---

# 📚 Everyday examples (4)

### Real cases

**Case 4: is this production?**

```yaml
# branch from inventory/group vars
# ✅ set_fact
- name: Check prod
  set_fact:
    is_production: "{{ env == 'prod' }}"

- name: Hardened prod template
  template:
    src: secure.conf.j2
    dest: /etc/app/security.conf
  when: is_production
```

---

# 📚 Everyday examples (5)

### Real cases

**Case 5: deploy timestamp**

```yaml
# changes every run
# ✅ set_fact
- name: Generate timestamp
  set_fact:
    deploy_timestamp: "{{ ansible_date_time.iso8601 }}"

- name: Compose version tag
  set_fact:
    version_tag: "{{ app_version }}-{{ deploy_timestamp }}"
```

---

# 📚 Everyday examples (6)

### Real cases

**Case 6: parse command output**

```yaml
# data shaping
# ✅ set_fact
- name: Read docker version string
  shell: docker --version
  register: docker_result

- name: Extract semver
  set_fact:
    docker_version: "{{ docker_result.stdout | regex_search('([0-9]+\\.[0-9]+)') }}"

- name: Enforce minimum
  fail:
    msg: "Docker {{ docker_version }} too old"
  when: docker_version is version('24.0', '<')
```

---

# 🎓 Further reading

### Official docs

**Facts**:
- full dump: `ansible -m setup hostname`
- guide: [docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html)

**set_fact**:
- module: [docs.ansible.com/ansible/latest/collections/ansible/builtin/set_fact_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/set_fact_module.html)

**Variable precedence**:
- [docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence)

---

# Debug: debug

### Print information

```yaml
# simple message
- name: Print message
  debug:
    msg: "Deploying {{ app_name }} version {{ app_version }}"

# dump one variable
- name: Debug variable
  debug:
    var: ansible_hostname

# multi-line summary
- name: Verbose host summary
  debug:
    msg: |
      Hostname: {{ ansible_hostname }}
      IP: {{ ansible_default_ipv4.address }}
      OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
```

---

# Debug: debug (continued)

```yaml
# only when verbosity >= 2
- name: Verbose hostvars dump
  debug:
    var: hostvars[inventory_hostname]
    verbosity: 2

# inspect task output
- name: Check disk space
  shell: df -h
  register: disk_space

- name: Show disk info
  debug:
    var: disk_space.stdout_lines

# pretty JSON
- name: Show config object
  debug:
    msg: "{{ app_config | to_nice_json }}"
```

---

# Variables: include_vars

### Load vars from files

```yaml
# per-environment file
- name: Load environment vars
  include_vars:
    file: "vars/{{ environment }}.yml"

# load into a namespace
- name: Load app config dict
  include_vars:
    file: config.yml
    name: app_config

# OS-specific file name
- name: Load OS-specific vars
  include_vars: "{{ ansible_distribution }}.yml"
```

---

# Facts vs set_fact: the difference

### Two different ideas

**Facts** (`ansible_facts`) = **automatic discovery**
- gathered at play start (unless disabled)
- OS, CPU, RAM, network, disks…
- read-only — you do not “create” them with `set_fact`

**set_fact** = **facts you define**
- created during the play
- calculations, branches, transformations
- mutable host variables

---

# Facts: setup (automatic gather)

### System information

```yaml
# default: gather_facts: yes (automatic)
- hosts: all
  tasks:
    - debug:
        msg: "OS: {{ ansible_facts['distribution'] }}"

# run setup manually
- name: Gather facts
  setup:

# subset with filter
- name: Network-related facts only
  setup:
    filter: ansible_*_ipv4
```

---

# Facts: disable gathering

### Faster plays when you do not need facts

```yaml
# skip fact gathering
- hosts: all
  gather_facts: no
  tasks:
    - name: Simple ping
      ping:

# gather later in the play
- hosts: all
  gather_facts: no
  tasks:
    - name: Work without facts first
      debug:
        msg: "No facts yet"
    
    - name: Gather facts now
      setup:
    
    - debug:
        msg: "OS: {{ ansible_facts['distribution'] }}"
```

---

# Facts: most useful keys

### Common system fields

```yaml
- hosts: all
  tasks:
    - name: Show useful facts
      debug:
        msg: |
          Hostname: {{ ansible_facts['hostname'] }}
          FQDN: {{ ansible_facts['fqdn'] }}
          OS: {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}
          Architecture: {{ ansible_facts['architecture'] }}
          CPUs: {{ ansible_facts['processor_vcpus'] }}
          Total RAM: {{ ansible_facts['memtotal_mb'] }} MB
          Primary IP: {{ ansible_facts['default_ipv4']['address'] }}
          All IPv4: {{ ansible_facts['all_ipv4_addresses'] }}
```

---

# Facts: practical examples

### Use in `when:`

```yaml
- hosts: all
  tasks:
    - name: Install on Debian family
      apt:
        name: nginx
        state: present
      when: ansible_facts['os_family'] == "Debian"

    - name: Install on RedHat family
      yum:
        name: nginx
        state: present
      when: ansible_facts['os_family'] == "RedHat"

    - name: Tune config from RAM
      template:
        src: app.conf.j2
        dest: /etc/app.conf
      vars:
        worker_processes: "{{ ansible_facts['processor_vcpus'] }}"
        max_memory: "{{ (ansible_facts['memtotal_mb'] * 0.7) | int }}"
```

---

# Custom facts (local facts)

### Ship your own `.fact` files

**Use cases**: app metadata on the host
- deployed app version
- last deploy timestamp
- business-specific flags

```yaml
- name: Install custom fact file
  copy:
    content: |
      [general]
      app_version=1.2.3
      deployed_at={{ ansible_date_time.iso8601 }}
      deployed_by={{ lookup('env', 'USER') }}
    dest: /etc/ansible/facts.d/myapp.fact
    mode: '0644'
```

**📁 Path**: `/etc/ansible/facts.d/*.fact`

---

# Custom facts: consumption

### Read `ansible_local`

```yaml
# refresh after writing .fact
- name: Refresh facts
  setup:

# read values
- name: Show deployed version
  debug:
    msg: "App version: {{ ansible_local.myapp.general.app_version }}"

# use in templates
- name: Render status page
  template:
    src: status.html.j2
    dest: /var/www/status.html
```

**status.html.j2** :

```html
<p>Version: {{ ansible_local.myapp.general.app_version }}</p>
<p>Deployed: {{ ansible_local.myapp.general.deployed_at }}</p>
```

---

# Custom facts: JSON format

### INI alternative

```yaml
- name: Install JSON custom fact
  copy:
    content: |
      {
        "app": {
          "name": "myapp",
          "version": "1.2.3",
          "environment": "production"
        },
        "database": {
          "host": "db.example.com",
          "port": 5432
        }
      }
    dest: /etc/ansible/facts.d/myapp.fact
    mode: '0644'

- setup:

- debug:
    msg: "DB host: {{ ansible_local.myapp.database.host }}"
```

---

# Facts vs set_fact: full comparison

### Side by side

| Aspect | **Facts** (`setup`) | **set_fact** |
|--------|---------------------|--------------|
| **Source** | system (auto gather) | you (explicit) |
| **When** | start of play (default) | during the play |
| **Mutable** | ❌ read-only | ✅ yes |
| **Content** | OS/hardware/network | branches, math, custom data |
| **Examples** | `ansible_facts['hostname']` | `is_prod`, derived counters |
| **Storage** | in-memory per host | in-memory per host |
| **Scope** | per host | per host |
| **Cost** | upfront gather | each `set_fact` call |

---

# Full example: facts + set_fact

### Combine both

```yaml
- hosts: webservers
  vars:
    env: "prod"
  
  tasks:
    # facts gathered automatically
    - name: Show system info
      debug:
        msg: "Server: {{ ansible_facts['hostname'] }}, OS: {{ ansible_facts['distribution'] }}"
    
    # set_fact for derived tuning
    - name: Derive tuning from hardware
      set_fact:
        is_prod: "{{ env == 'prod' }}"
        max_workers: "{{ ansible_facts['processor_vcpus'] * 2 }}"
        cache_size: "{{ (ansible_facts['memtotal_mb'] * 0.1) | int }}"
    
    # use together in template vars
    - name: Deploy config
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
```

---

# Practical example: auto-tune from facts

### Fact-driven decisions

```yaml
- hosts: all
  tasks:
    - name: Classify host from resources
      set_fact:
        deployment_type: "{{ 'high-perf' if ansible_facts['memtotal_mb'] > 8000 else 'standard' }}"
        is_ssd: "{{ ansible_facts['devices']['sda']['model'] is search('SSD') }}"
        needs_swap: "{{ ansible_facts['memtotal_mb'] < 2000 }}"

    - name: Add swap when RAM is low
      command: |
        dd if=/dev/zero of=/swapfile bs=1M count=2048
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
      when: needs_swap

    - name: Lower swappiness on SSD
      sysctl:
        name: vm.swappiness
        value: "1"
      when: is_ssd

    - debug:
        msg: "Profile {{ deployment_type }} applied"
```

---
layout: new-section
---

# 📝 Git & Version Control

---

# Git: `git` module

### Clone and update repositories

```yaml
# clone a repo
- name: Clone application
  git:
    repo: https://github.com/user/app.git
    dest: /opt/app
    version: main

# specific branch
- name: Clone develop branch
  git:
    repo: https://github.com/user/app.git
    dest: /opt/app-dev
    version: develop

# private repo with token
- name: Clone private repository
  git:
    repo: https://{{ github_token }}@github.com/user/private-app.git
    dest: /opt/private-app
```

---

# Git: `git` (continued)

```yaml
# pin to a commit
- name: Checkout commit
  git:
    repo: https://github.com/user/app.git
    dest: /opt/app
    version: abc123def456

# pull latest
- name: Update repository
  git:
    repo: https://github.com/user/app.git
    dest: /opt/app
    update: yes
    force: yes

# clone over SSH
- name: Clone via SSH
  git:
    repo: git@github.com:user/app.git
    dest: /opt/app
    key_file: /home/deploy/.ssh/id_rsa
    accept_hostkey: yes
```

---
layout: new-section
---

# 🔄 Control flow

---

# Control: `when` (conditions)

### Conditional execution

```yaml
# simple condition
- name: Install nginx on Ubuntu
  apt:
    name: nginx
  when: ansible_distribution == "Ubuntu"

# multiple conditions (AND)
- name: Run production action
  command: /opt/app/prod-script.sh
  when:
    - environment == "production"
    - app_version is version('2.0', '>=')

# OR
- name: Install on Debian or Ubuntu
  apt:
    name: nginx
  when: ansible_distribution == "Debian" or ansible_distribution == "Ubuntu"
```

---

# Control: `when` (continued)

```yaml
# from a previous register
- name: Check if config file exists
  stat:
    path: /opt/app/config.yml
  register: config_file

- name: Create config when missing
  template:
    src: config.yml.j2
    dest: /opt/app/config.yml
  when: not config_file.stat.exists

# only when variable is defined
- name: Use custom port
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  when: custom_port is defined
```

---

# Control: `loop`

### Iterate over lists

```yaml
# simple loop
- name: Install several packages
  apt:
    name: "{{ item }}"
  loop:
    - nginx
    - git
    - curl
    - vim

# list of dicts
- name: Create users
  user:
    name: "{{ item.name }}"
    groups: "{{ item.groups }}"
  loop:
    - { name: 'alice', groups: 'sudo,docker' }
    - { name: 'bob', groups: 'docker' }
```

---

# Control: `loop` (continued)

```yaml
# numeric range
- name: Create containers
  community.docker.docker_container:
    name: "app-{{ item }}"
    image: myapp:latest
  loop: "{{ range(1, 4) | list }}"  # 1, 2, 3

# loop + when
- name: Create directories
  file:
    path: "/opt/{{ item }}"
    state: directory
  loop:
    - app
    - logs
    - data
  when: item != "logs" or enable_logging

# with index
- name: Deploy replicas
  debug:
    msg: "Deploy replica {{ item.0 + 1 }}: {{ item.1 }}"
  loop: "{{ apps | enumerate }}"
```

---

# Control: `block` (grouping)

### Group related tasks

```yaml
# simple block
- block:
    - name: Install nginx
      apt:
        name: nginx
    
    - name: Start nginx
      service:
        name: nginx
        state: started
  when: install_webserver

# block + rescue + always
- block:
    - name: Risky task
      command: /opt/risky-command.sh
  rescue:
    - name: On failure
      debug:
        msg: "Command failed, rollback..."
  always:
    - name: Always run
      debug:
        msg: "Cleanup..."
```

---

# Control: `failed_when`

### When to mark a task as failed

```yaml
# Custom fail condition
- name: Check application status
  shell: /opt/app/healthcheck.sh
  register: health
  failed_when: "'ERROR' in health.stdout"

# ignore some failure cases
- name: Check optional service
  service:
    name: optional-service
    state: started
  register: service_result
  failed_when: 
    - service_result.failed
    - "'could not be found' not in service_result.msg"

# multiple failure predicates
- name: Verify deployment
  shell: curl -f http://localhost/health
  register: health_check
  failed_when:
    - health_check.rc != 0
    - health_check.stdout != "OK"
```

💡 **Note**: prefer `service` for broader compatibility (including Docker setups).

---

# Control: `changed_when`

### When a task should report `changed`

```yaml
# always report changed
- name: Always report changed
  command: /opt/notification.sh
  changed_when: true

# never report changed
- name: Check only command
  command: /opt/check-status.sh
  changed_when: false

# Condition custom
- name: Update config if different
  shell: diff /tmp/new.conf /etc/app.conf
  register: diff_result
  changed_when: diff_result.rc != 0
  failed_when: false
```

---

# Control: `ignore_errors`

### Keep the play going

```yaml
# swallow task errors
- name: Try to stop service
  service:
    name: optional-service
    state: stopped
  ignore_errors: yes

# play continues
- name: Cleanup old files
  file:
    path: "/tmp/old-{{ item }}"
    state: absent
  loop:
    - file1
    - file2
    - file3
  ignore_errors: yes
```

---

# Control: `delegate_to`

### Run the task elsewhere

```yaml
# another inventory host
- name: Update load balancer
  command: /opt/update-lb.sh
  delegate_to: loadbalancer

# control node / localhost
- name: Build artifact locally
  shell: npm run build
  delegate_to: localhost

# loop + delegate
- name: Register with monitoring
  uri:
    url: http://monitoring.local/api/register
    method: POST
    body: "{{ inventory_hostname }}"
  delegate_to: monitoring-server
```

---

# Control: `run_once`

### Run on a single host

```yaml
# once per play (first host in batch)
- name: Initialize database
  command: /opt/app/init-db.sh
  run_once: yes

# with delegate
- name: Send deployment notification
  slack:
    msg: "Deployment started"
  run_once: yes
  delegate_to: localhost
```

---
layout: new-section
---

# ⏰ Scheduled tasks

---

# Cron: `cron`

### Schedule jobs

```yaml
# daily cron job
- name: Daily backup
  cron:
    name: "Daily backup"
    minute: "0"
    hour: "2"
    job: "/opt/scripts/backup.sh"
    user: root

# every N minutes
- name: Check every 15 minutes
  cron:
    name: "Health check"
    minute: "*/15"
    job: "/opt/scripts/healthcheck.sh"

# specific weekday
- name: Weekly report
  cron:
    name: "Weekly report"
    minute: "0"
    hour: "9"
    weekday: "1"
    job: "/opt/scripts/weekly-report.sh"
```

---

# Cron: `cron` (continued)

```yaml
# remove a job by name
- name: Remove old cron
  cron:
    name: "Old backup"
    state: absent

# at reboot
- name: Run at reboot
  cron:
    name: "Startup script"
    special_time: reboot
    job: "/opt/scripts/startup.sh"

# silence stdout/stderr
- name: Silent cron job
  cron:
    name: "Silent task"
    minute: "30"
    hour: "3"
    job: "/opt/scripts/task.sh > /dev/null 2>&1"
```

---

# Systemd: timer units

### Modern cron alternative (VMs / bare metal only)

⚠️ **Warning**: systemd timers do **not** run inside typical Docker containers — use `cron` there instead.

```yaml
# unit that runs the script
- name: Create systemd service
  copy:
    content: |
      [Unit]
      Description=Backup Service
      
      [Service]
      Type=oneshot
      ExecStart=/opt/scripts/backup.sh
    dest: /etc/systemd/system/backup.service

# timer unit
- name: Create systemd timer
  copy:
    content: |
      [Unit]
      Description=Backup Timer
      
      [Timer]
      OnCalendar=daily
      Persistent=true
      
      [Install]
      WantedBy=timers.target
    dest: /etc/systemd/system/backup.timer
```

---

# Systemd: timer (continued)

```yaml
# enable + start
- name: Enable and start timer
  service:
    name: backup.timer
    enabled: yes
    state: started
```

⚠️ **Reminder**: timers need a real init system — not plain Docker.

---
layout: new-section
---

# 🔐 Security & certificates

---

# SSL: `community.crypto` (OpenSSL)

### TLS keys, CSRs, certificates

```yaml
# private key
- name: Generate private key
  community.crypto.openssl_privatekey:
    path: /etc/ssl/private/example.com.key
    size: 4096

# CSR
- name: Generate CSR
  community.crypto.openssl_csr:
    path: /etc/ssl/certs/example.com.csr
    privatekey_path: /etc/ssl/private/example.com.key
    common_name: example.com
    subject_alt_name:
      - DNS:example.com
      - DNS:www.example.com

# self-signed cert
- name: Generate self-signed certificate
  community.crypto.x509_certificate:
    path: /etc/ssl/certs/example.com.crt
    privatekey_path: /etc/ssl/private/example.com.key
    csr_path: /etc/ssl/certs/example.com.csr
    provider: selfsigned
```

---

# Firewall: UFW (Ubuntu)

### Uncomplicated Firewall

```yaml
# enable UFW
- name: Enable UFW
  community.general.ufw:
    state: enabled
    policy: deny

# allow SSH
- name: Allow SSH
  community.general.ufw:
    rule: allow
    port: '22'
    proto: tcp

# HTTP / HTTPS
- name: Allow web traffic
  community.general.ufw:
    rule: allow
    port: "{{ item }}"
    proto: tcp
  loop:
    - '80'
    - '443'
```

---

# Firewall: UFW (continued)

```yaml
# allow from one source IP
- name: Allow from specific IP
  community.general.ufw:
    rule: allow
    from_ip: 192.168.1.100
    to_port: '3306'

# delete rule
- name: Delete rule
  community.general.ufw:
    rule: allow
    port: '8080'
    delete: yes
```

---

# Firewall: firewalld (RHEL family)

### Dynamic firewall

```yaml
# start + enable
- name: Enable firewalld
  service:
    name: firewalld
    state: started
    enabled: yes

# predefined service
- name: Allow HTTP service
  ansible.posix.firewalld:
    service: http
    permanent: yes
    state: enabled
    immediate: yes

# custom port
- name: Allow custom port
  ansible.posix.firewalld:
    port: 8080/tcp
    permanent: yes
    state: enabled
```

---

# SELinux: booleans & file context

### Hardening helpers

```yaml
# toggle boolean
- name: Allow httpd network connect
  ansible.posix.seboolean:
    name: httpd_can_network_connect
    state: yes
    persistent: yes

# file context pattern
- name: Set SELinux context
  community.general.sefcontext:
    target: '/opt/app(/.*)?'
    setype: httpd_sys_content_t
    state: present

# apply labels
- name: Apply SELinux context
  command: restorecon -Rv /opt/app
```

---
layout: new-section
---

# 📊 Monitoring & Logs

---

# Logs: syslog

### Send structured log lines

```yaml
# basic message
- name: Log deployment
  community.general.syslogger:
    msg: "Deployment of {{ app_name }} v{{ app_version }} started"
    priority: info

# priority + facility
- name: Log critical event
  community.general.syslogger:
    msg: "Critical error during deployment"
    priority: crit
    facility: daemon
```

---

# Monitoring: `stat`

### Inspect files and directories

```yaml
# does the file exist?
- name: Check config exists
  stat:
    path: /etc/app/config.yml
  register: config_stat

- name: Show file info
  debug:
    msg: |
      Exists: {{ config_stat.stat.exists }}
      Size: {{ config_stat.stat.size | default(0) }}
      Owner: {{ config_stat.stat.pw_name | default('unknown') }}
  when: config_stat.stat.exists

# enforce permissions
- name: Verify permissions
  stat:
    path: /opt/app/secrets
  register: secrets_dir
  failed_when: 
    - secrets_dir.stat.exists
    - secrets_dir.stat.mode != '0700'
```

---

# Monitoring: `service_facts`

### Service states from the target

```yaml
# populate ansible_facts.services
- name: Get service facts
  service_facts:

# is nginx running?
- name: Verify nginx running
  debug:
    msg: "Nginx is {{ ansible_facts.services['nginx.service'].state }}"
  when: "'nginx.service' in ansible_facts.services"

# List all running services
- name: Show running services
  debug:
    msg: "{{ item }}"
  loop: "{{ ansible_facts.services.keys() | list }}"
  when: ansible_facts.services[item].state == "running"
```

---

# System: `reboot`

### Controlled restarts

```yaml
# simple reboot
- name: Reboot server
  reboot:

# delays + timeout
- name: Reboot with message
  reboot:
    msg: "Reboot initiated by Ansible"
    pre_reboot_delay: 0
    post_reboot_delay: 30
    reboot_timeout: 600

# conditional reboot
- name: Reboot if kernel updated
  reboot:
  when: kernel_updated
```

---

# System: `hostname`

### Set the node name

```yaml
# short name
- name: Set server hostname
  hostname:
    name: web-server-01

# FQDN
- name: Set FQDN
  hostname:
    name: web01.example.com
```

---

# System: `timezone`

### Set TZ data

```yaml
# example region
- name: Set timezone to UTC
  community.general.timezone:
    name: UTC

# variable-driven
- name: Set timezone based on location
  community.general.timezone:
    name: "{{ server_timezone }}"
```

---

# End of cheat sheet 🎉

### You now have a broad module map

**This section covers**:
- ✅ 100+ Ansible modules (representative samples)
- ✅ Copy-paste friendly patterns
- ✅ Core categories for day-to-day automation
- ✅ Embedded good practices

**How to use it**: keep it open while you author playbooks and roles.

**💡 Tip**: run `ansible-doc <module>` for full option lists and examples.

---

# Capstone project: overview 🎯

### End-to-end orchestration (Rocky Linux reference)

Deploy a **complete stack** on **Ubuntu + Rocky Linux** hosts:

```
users & sudo → LVM storage → OpenLDAP → snmpd
```

**Skills combined**: inventories, roles, handlers, templates, tags, idempotence.

---

# Capstone: multi-OS inventory — OS-specific tasks 🎯

### Ubuntu vs Rocky Linux

Use `ansible_os_family` or group vars to pick `apt` vs `dnf` inside roles.