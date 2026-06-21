# Reference solution — group Ansible exercise

## Description

This reference layout demonstrates a full mini-stack with Ansible:

- **Two Apache2 hosts** (`apache1`, `apache2`)
- **Two Nginx hosts** (`nginx1`, `nginx2`)
- Dedicated playbooks per stack
- Complete roles (tasks, handlers, templates, variables)
- Docker Compose for local testing

## Project structure

```
correction/
├── ansible.cfg                 # roles_path, callbacks, etc.
├── group_vars/
│   └── all.yml                 # e.g. ansible_connection: docker
├── inventories/
│   ├── apache2.yml             # Apache group
│   └── nginx.yml               # Nginx group
├── playbooks/
│   ├── play-apache2.yml
│   └── play-nginx.yml
├── roles/
│   ├── apache2/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/
│   │   │   ├── apache2.conf.j2
│   │   │   └── index.html.j2
│   │   └── vars/main.yml
│   └── nginx/
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       ├── templates/
│       │   ├── nginx.conf.j2
│       │   └── index.html.j2
│       └── vars/main.yml
├── docker-compose.yml
└── README.md
```

## Install and run

### 1. Start Docker

```bash
cd correction/
docker-compose up -d
docker ps
```

### 2. Apache playbooks

```bash
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml
```

### 3. Nginx playbooks

```bash
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml
```

### 4. Smoke tests

#### Apache2

```bash
docker exec -it apache-server-1 bash
service apache2 status
curl http://localhost
exit
```

#### Nginx

```bash
docker exec -it nginx-server-1 bash
service nginx status
curl http://localhost:8080
exit
```

#### From the host browser

- Nginx 1: http://localhost:8080  
- Nginx 2: http://localhost:8081  

## Key teaching points

### 1. `ansible.cfg`

```ini
[defaults]
roles_path = ./roles
host_key_checking = False
stdout_callback = yaml
```

Sets project-local Ansible behavior.

### 2. `group_vars/all.yml`

```yaml
ansible_connection: docker
```

Lets the control node drive containers as managed nodes (requires `community.docker` and running containers).

### 3. Split inventories

- `apache2.yml` — group `apache_servers` (`apache1`, `apache2`)
- `nginx.yml` — group `nginx_servers` (`nginx1`, `nginx2`)

### 4. Playbooks

- `play-apache2.yml` → `hosts: apache_servers`, role `apache2`
- `play-nginx.yml` → `hosts: nginx_servers`, role `nginx`

### 5. Roles

Each role includes:

- `tasks/main.yml` — install & configure  
- `handlers/main.yml` — reload / restart  
- `templates/` — Jinja-driven config and HTML  
- `vars/main.yml` — role defaults / constants  

### 6. Templates

Templates consume variables for ports, paths, per-host HTML, etc.

### 7. Handlers

Handlers run only when notified after a real change (idempotency).

## Useful commands

### Inventory checks

```bash
ansible -i inventories/apache2.yml all --list-hosts
ansible -i inventories/nginx.yml all --list-hosts
ansible -i inventories/apache2.yml all -m ping
```

### Check mode

```bash
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml --check
```

### Verbosity

```bash
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml -v
```

## Cleanup

```bash
docker-compose down
docker-compose down -v   # also remove volumes
```

## Ansible concepts covered

1. Inventories and groups  
2. Playbooks  
3. Roles  
4. Variables  
5. Templates  
6. Handlers  
7. Modules such as `apt`, `service`, `file`, `template`  
8. Idempotent reruns  

## Operational notes

- Start Compose **before** running playbooks.  
- Python 3 is expected inside the lab images.  
- `ansible_connection: docker` is defined in `group_vars/all.yml`.  
- Nginx ports are published for browser checks.  
- Apache listens on port 80 inside the containers.  
- Nginx listens on 8080 inside the container (mapped on the host as documented in Compose).  

## Optional extensions

1. Add a variable for the HTML welcome message.  
2. Add a MySQL role.  
3. Add log rotation tasks.  
4. Sketch TLS termination.  
5. Single playbook that applies both roles in one graph.  

---

Reference solution validated with **Ansible 2026** and **Docker** in the training environment.
