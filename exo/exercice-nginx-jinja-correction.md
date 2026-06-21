# Solution — Ansible variables + Jinja2 template (`nginx.conf`)

This document describes the **reference solution** and how to **validate** it against the root `docker-compose-lab.yml` lab.

---

## Provided files

The runnable tree is in:

`exo/correction-nginx-jinja/`

| File | Role |
|--------|------|
| `inventory.yml` | Group `webservers` → containers `ansible-lab-web01` … `web03`, `docker` connection |
| `group_vars/webservers.yml` | Variables consumed by the template |
| `templates/nginx.conf.j2` | Jinja2 template (conditions, loops, `ansible_managed`) |
| `playbook.yml` | Install, template deploy, Nginx lifecycle in the container |
| `test-lab.sh` | Regression script (playbook + `nginx -t` + HTTP) |

---

## Design details

- **Port 8080**: `nginx_listen_port` is `8080` to avoid conflicts if another service uses port 80 (e.g. Apache exercises on the same lab). Students may use 80 on a fresh lab; the exercise stresses a port variable for this reason.
- **Template**: `{% if nginx_enable_gzip %}` for the gzip block; loops over `nginx_index_files`, `nginx_gzip_types`, and `nginx_extra_headers.items()`.
- **`server_name`**: `{{ inventory_hostname }}.lab.local` to differentiate the three nodes without duplicating inventory.
- **Playbook**: stop `nginx` processes, remove leftover `/run/nginx.pid`, `nginx -t`, then `nginx` — robust pattern in these containers without systemd after full `nginx.conf` replacement.
- **Copy validation**: `validate: nginx -t -c %s` on the `template` module.

---

## Test executed (status)

The solution was run successfully with:

1. `docker compose -f docker-compose-lab.yml up -d` (from repo root);
2. `cd exo/correction-nginx-jinja && ./test-lab.sh`;

Result: **playbook OK** on `web01`–`web03`, **`nginx -t` OK**, **HTTP 200** on `http://127.0.0.1:8080` in each container.

---

## Re-run the test locally

```bash
# Repository root
docker compose -f docker-compose-lab.yml up -d

cd exo/correction-nginx-jinja
chmod +x test-lab.sh   # once if needed
./test-lab.sh
```

---

## Reference content (copy)

### `inventory.yml`

```yaml
---
# Inventory aligned with docker-compose-lab.yml (webservers group).
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

### `group_vars/webservers.yml`

```yaml
---
# Group variables consumed by templates/nginx.conf.j2
nginx_worker_connections: 2048
# 8080 avoids conflict if Apache (other exercises) already uses port 80 on the lab
nginx_listen_port: 8080
# server_name depends on the node (Ansible hostname)
nginx_server_name: "{{ inventory_hostname }}.lab.local"
nginx_docroot: /var/www/html
nginx_index_files:
  - index.html
  - index.htm
nginx_enable_gzip: true
nginx_gzip_types:
  - text/plain
  - text/css
  - application/javascript
  - application/json
nginx_client_max_body_size: 2m
# Optional headers (Jinja loop in template)
nginx_extra_headers:
  X-Lab-Exercise: "nginx-jinja"
  X-Frame-Options: "SAMEORIGIN"
```

### `templates/nginx.conf.j2`

```nginx
# {{ ansible_managed }}
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections {{ nginx_worker_connections }};
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access.log;
    sendfile on;
    keepalive_timeout 65;
    client_max_body_size {{ nginx_client_max_body_size }};

{% if nginx_enable_gzip %}
    gzip on;
    gzip_vary on;
    gzip_min_length 256;
    gzip_types {% for t in nginx_gzip_types %}{{ t }}{% if not loop.last %} {% endif %}{% endfor %};
{% endif %}

    server {
        listen {{ nginx_listen_port }};
        server_name {{ nginx_server_name }};
        root {{ nginx_docroot }};
        index {% for f in nginx_index_files %}{{ f }}{% if not loop.last %} {% endif %}{% endfor %};

{% for header_name, header_value in nginx_extra_headers.items() %}
        add_header {{ header_name }} "{{ header_value }}";
{% endfor %}

        location / {
            try_files $uri $uri/ =404;
        }
    }
}
```

### `playbook.yml`

```yaml
---
- name: Nginx via variables and Jinja2 template
  hosts: webservers
  gather_facts: true
  become: false

  tasks:
    - name: Install nginx packages
      ansible.builtin.apt:
        name: nginx
        state: present
        update_cache: true

    - name: Ensure document root directory
      ansible.builtin.file:
        path: "{{ nginx_docroot }}"
        state: directory
        mode: "0755"

    - name: Minimal home page
      ansible.builtin.copy:
        dest: "{{ nginx_docroot }}/index.html"
        mode: "0644"
        content: |
          <!DOCTYPE html>
          <html lang="en"><head><meta charset="utf-8"><title>{{ inventory_hostname }}</title></head>
          <body><h1>{{ inventory_hostname }}</h1><p>Lab nginx + Jinja2</p></body></html>

    - name: Deploy nginx.conf from template
      ansible.builtin.template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        mode: "0644"
        validate: nginx -t -c %s

    - name: Stop nginx (pidfile often stale in container after conf change)
      ansible.builtin.shell: pkill -x nginx
      failed_when: false
      changed_when: false

    - name: Remove leftover pidfile if any
      ansible.builtin.file:
        path: /run/nginx.pid
        state: absent

    - name: Verify nginx syntax
      ansible.builtin.command:
        cmd: nginx -t
      changed_when: false

    - name: Start nginx
      ansible.builtin.command: nginx
```

---

## Teaching variant

To force port 80 on a fresh lab, set `nginx_listen_port: 80` in `group_vars/webservers.yml` and adapt the URL in `test-lab.sh` (or stop any service using port 80 before testing).
