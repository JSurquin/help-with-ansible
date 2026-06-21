---
layout: new-section
routeAlias: 'reference-intro'
---

# Cloud inventories & advanced handlers ☁️

Reference supplement for the Ansible training: dynamic cloud inventories (Azure, GCP, AWS), hybrid setups, auto-scaling, and in-depth handler patterns.

---

# Inventory plugin: Azure

### Azure RM configuration

```yaml
# inventory_azure.yml
plugin: azure.azcollection.azure_rm

auth_source: auto

include_vm_resource_groups:
  - production-rg
  - staging-rg

conditional_groups:
  production: "tags.environment == 'production'"
  staging: "tags.environment == 'staging'"
  webservers: "tags.role == 'web'"

hostnames:
  - default

compose:
  ansible_host: public_ipv4_addresses[0]
  ansible_user: azureuser
```

---

# Inventory plugin: GCP

### Google Cloud configuration

```yaml
# inventory_gcp.yml
plugin: google.cloud.gcp_compute

projects:
  - my-project-id

regions:
  - europe-west1
  - europe-west4

filters:
  - status = RUNNING
  - labels.environment = production

keyed_groups:
  - key: labels.environment
    prefix: env
  - key: labels.role
    prefix: role

hostnames:
  - public_ip
  - name

compose:
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
```

---

# Full example: hybrid infrastructure (part 2)

```yaml
# inventory/aws.yml - Cloud servers
plugin: amazon.aws.aws_ec2
regions:
  - eu-west-1
filters:
  instance-state-name: running
keyed_groups:
  - key: tags.Environment
    prefix: env
```

---

# Full example: hybrid infrastructure (part 3)

```yaml
# inventory/docker.yml - Local containers
plugin: community.docker.docker_containers
filters:
  status: running
keyed_groups:
  - key: docker_labels.service
    prefix: service
compose:
  ansible_connection: docker
```

---

# Hybrid inventory result

### All servers reachable

```bash
ansible-inventory -i ./inventory/ --graph

@all:
  |--@onpremise:
  |  |--control-node
  |--@aws_ec2:
  |  |--@env_production:
  |  |  |--web-prod-01.aws
  |  |  |--db-prod-01.aws
  |--@docker_containers:
  |  |--@service_web:
  |  |  |--nginx-dev-01
  |  |  |--nginx-dev-02
```

**Playbook**: can target any group!

---

# Use case: auto-scaling

### Infrastructure that keeps changing

**Problem**: auto-scaling adds/removes instances

```yaml
# Dynamic AWS inventory
plugin: amazon.aws.aws_ec2
regions:
  - eu-west-1
filters:
  tag:AutoScaling: "true"
  instance-state-name: running
```

**Outcome**:
- Ansible queries AWS on every run
- List always current (even with auto-scaling)
- No manual inventory edits needed

---

# Use case: ephemeral containers

### Docker Swarm or Kubernetes

```yaml
# inventory_docker_swarm.yml
plugin: community.docker.docker_swarm

docker_host: tcp://manager-node:2376

include_host_uri: true

filters:
  - node_role == "worker"
  - node_state == "ready"

compose:
  ansible_connection: ssh
  ansible_host: node_addr
```

**Benefit**: automatically discovers swarm workers

---

---

# Handlers: multi-replica `loop` + `notify`

### `loop` **and** real handler chaining: after N containers, **one** front proxy reload if any task changed

Same handler name on every iteration: it still runs **once** at end of play (unless `meta: flush_handlers`).

```yaml
# Play fragment: one task per replica, then one handler (e.g. reverse proxy)
tasks:
  - name: Deploy app per environment
    community.docker.docker_container:
      name: 'webapp-{{ item }}'
      image: 'myapp:{{ app_version }}'
      ports:
        - '{{ 8080 + item }}:8080'
      env:
        ENV: '{{ env }}'
        REPLICA: '{{ item | string }}'
    loop: '{{ range(1, environments[env].replicas + 1) | list }}'
    notify: reload nginx reverse proxy

handlers:
  - name: reload nginx reverse proxy
    ansible.builtin.service:
      name: nginx
      state: reloaded
```

---

# Handlers: definition

```yaml
handlers:
  - name: restart docker
    service:
      name: docker
      state: restarted

  - name: reload nginx
    service:
      name: nginx
      state: reloaded
```

💡 **Note**: use `service` for Docker compatibility

---

# ✅ How a handler is triggered

### The name is the key

```yaml
tasks:
  - name: Change nginx config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: restart nginx  # ⚠️ MUST MATCH EXACTLY
```

```yaml
handlers:
  - name: restart nginx  # ⚠️ MUST MATCH EXACTLY
    service:
      name: nginx
      state: restarted
```

💡 **Note**: use `service` for Docker compatibility

---

# ❌ Common handler mistakes

### These will **never** fire:

```yaml
notify: restart nginx

handlers:
  - name: Restart nginx  # ❌ different case
  - name: restart_nginx  # ❌ underscore vs space
  - name: restart nginx service  # ❌ extra words
  - name: reload nginx  # ❌ different action
```

**The string in `notify` MUST match the handler `name` exactly**

---

# 🧠 Handlers: rule of thumb

> **Handler name = unique identifier**

- Case-sensitive (`restart` ≠ `Restart`)
- Space-sensitive (`restart nginx` ≠ `restart_nginx`)
- No aliases
- One `notify` string maps to one handler name

---

# 📁 Where do handlers live?

### Handlers are conditional tasks

```
ansible-project/
│
├── playbook.yml          # main playbook
│   ├── tasks:            # ← normal tasks
│   └── handlers:         # ← “reactive” tasks
│
└── inventory.ini
```

**Simple**: same YAML play, different top-level key.

---

# 📁 Handlers in separate files

### For larger projects

```
ansible-project/
│
├── playbook.yml
├── handlers/
│   ├── main.yml          # primary handlers
│   └── docker.yml        # docker handlers
│
└── tasks/
    └── setup.yml
```

```yaml
# playbook.yml
---
- hosts: all
  tasks:
    - include_tasks: tasks/setup.yml
  handlers:
    - include: handlers/main.yml
```

---

# ✅ Mini quiz: Module 10 — handlers

**Question 1**: when does a handler run?
- A) Immediately when notified
- B) At end of play, only if notified **and** the task reported `changed`
- C) At the start of the play

**Question 2**: how do you invoke a handler?
- A) `trigger: handler_name`
- B) `notify: handler_name`
- C) `call: handler_name`

**Question 3**: the handler name must be:
- A) identical to `notify:` (case-sensitive)
- B) anything; Ansible guesses
- C) uppercase only

---

# 📝 Mini quiz answers — Module 10

**Question 1**: **B** ✅  
Handlers run at the **end** of the play, only if notified **and** the notifying task actually changed something (`changed: true`).

**Question 2**: **B** ✅  
Use `notify: handler_name` on a task. The handler `name` must match exactly.

**Question 3**: **A** ✅  
Exact match: case, spaces, underscores. `restart nginx` ≠ `Restart nginx`.

---

# 🐛 Troubleshooting: handlers

### My handler never runs — why?

**Four usual causes**:

1. ❌ Mismatch between `notify` and handler `name`
2. ❌ Task did not change anything (`changed: false`)
3. ❌ Playbook failed before the end
4. ❌ `--check` mode

---

# 🐛 Cause 1: name mismatch

### The most common trap

```yaml
tasks:
  - name: Config nginx
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: restart nginx  # ⚠️ lowercase

handlers:
  - name: Restart nginx  # ❌ different case → never runs
```

**Fix**: 100% identical strings

```yaml
notify: restart nginx
handlers:
  - name: restart nginx  # ✅ match
```

---

# 🐛 Cause 2: changed: false

### Handlers run only when something changed

```yaml
# First run
TASK [template nginx.conf] *** changed: true
RUNNING HANDLER [restart nginx] ***  # ✅ runs

# Second run (file unchanged)
TASK [template nginx.conf] *** ok
# ❌ no handler (expected — idempotency!)
```

**By design**: no restart if nothing changed.

---

# 🐛 Cause 3: failed playbook

### Handlers run at the **end**

```yaml
tasks:
  - name: Config nginx
    template: ...
    notify: restart nginx  # notified ✅
  
  - name: Task that fails
    command: /bin/false  # ❌ failure → play stops
    
# ❌ handler never runs — play ended early
```

---

# 🐛 Cause 3: failed playbook (continued)

**Mitigation**: run notified handlers even on failure

```bash
# handlers may still run after a task failure
ansible-playbook site.yml --force-handlers
```

**Use when** you must bounce a service even if a later task fails.

---

# 🐛 Cause 4: check mode

### In check mode handlers do not run

```bash
# dry-run: simulate, no real changes
ansible-playbook site.yml --check

# Outcome:
# - tasks simulated ✅
# - handlers listed but NOT run ❌
```

**Expected**: `--check` does not change the system.

---

# 🎯 Hands-on: handlers and idempotency

### Exercise

```bash
# First run — handler should run
ansible-playbook playbook.yml -v

# In output look for:
# TASK [Config nginx] *** changed: true
# RUNNING HANDLER [restart nginx] ***  ✅

# Second run — handler should NOT run
ansible-playbook playbook.yml -v

# Look for:
# TASK [Config nginx] *** ok (not changed)
# no RUNNING HANDLER  ✅ expected
```

---

# 🎯 Hands-on: handlers (continued)

### If the handler runs **every** time

**Symptom**: handler runs even when nothing should change

```yaml
tasks:
  - name: Template
    template:
      src: app.conf.j2
      dest: /tmp/app.conf
    notify: restart app
# every run: changed: true → handler ✅
```

**Diagnosis**: template is not idempotent!

---

# 🎯 Hands-on: handlers (continued 2)

**Possible causes**:

1. Template embeds a changing date/timestamp
   ```jinja
   # ❌ problem
   Generated on: {{ ansible_date_time.iso8601 }}
   ```

2. Wrong permissions on `dest`
   ```yaml
   # check mode, owner, group
   template:
     src: app.conf.j2
     dest: /tmp/app.conf
     mode: '0644'  # ← matters
     owner: root
     group: root
   ```

---

# 💡 Handler best practices (2026)

### Takeaways

1. **Matching names**: `notify` string = handler `name`
2. **Idempotence**: handler only after real changes
3. **End of play**: default handler phase is last
4. **Once per play**: notify 10× → still one run (unless flushed)
5. **`--force-handlers`**: when you need handlers after errors

---

# Handlers vs normal tasks: when to use which?

### Decision guide

**Use a HANDLER when**:
- ✅ the work should run **only** if something changed
- ✅ it is a reaction (restart, reload, rebuild…)
- ✅ several tasks should trigger the **same** action
- ✅ the work can wait until the end of the play

**Use a normal TASK when**:
- ✅ the work must **always** run
- ✅ order is strict
- ✅ you need `register` output **immediately**

---

# Handlers vs tasks: examples

### ❌ Bad handler use

```yaml
# ❌ BAD: need output immediately
- name: Check disk space
  shell: df -h /
  register: disk_space
  notify: handle disk check

handlers:
  - name: handle disk check
    debug:
      msg: "{{ disk_space.stdout }}"  # ❌ register not available yet!
```

---

# Handlers vs tasks: examples (continued)

### ✅ Good handler use

```yaml
# ✅ GOOD: deferred restart
- name: Update nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: restart nginx

- name: Update SSL cert
  copy:
    src: cert.pem
    dest: /etc/nginx/ssl/cert.pem
  notify: restart nginx

# handler runs once at end even if two tasks notify
handlers:
  - name: restart nginx
    service:
      name: nginx
      state: restarted
```

---

# Handlers: notify multiple

### Notify several handlers at once

```yaml
tasks:
  - name: Update app config
    template:
      src: app.conf.j2
      dest: /etc/app/app.conf
    notify:
      - restart app
      - send notification
      - update monitoring

handlers:
  - name: restart app
    service:
      name: myapp
      state: restarted

  - name: send notification
    slack:
      msg: "App config updated on {{ inventory_hostname }}"

  - name: update monitoring
    uri:
      url: "https://monitoring.example.com/api/update"
      method: POST
```

---

# Handlers: `listen` (grouping)

### Group handlers under one logical name

**Problem**: repeating many handler names everywhere

```yaml
# ❌ repetitive
notify:
  - restart nginx
  - reload haproxy
  - flush cache
  - update monitoring
```

**Fix**: use `listen` to group

```yaml
tasks:
  - name: Update config
    template:
      src: app.conf.j2
      dest: /etc/app.conf
    notify: update webserver
```

---

# Handlers: `listen` (continued)

```yaml
handlers:
  - name: restart nginx
    service:
      name: nginx
      state: restarted
    listen: update webserver

  - name: reload haproxy
    service:
      name: haproxy
      state: reloaded
    listen: update webserver

  - name: flush cache
    command: redis-cli FLUSHALL
    listen: update webserver

  - name: update monitoring
    uri:
      url: "https://monitoring.example.com/api/update"
    listen: update webserver
```

**💡 With `listen`**: one `notify: update webserver` runs all four handlers!

---

# Handlers: `listen` — use cases

### When to use `listen`

**✅ Use `listen` when**:
- several handlers must run as a set
- you want one logical name for a bundle of actions
- you want to avoid repeating long `notify` lists

**Real example**: web deploy

```yaml
- name: Deploy frontend
  copy:
    src: dist/
    dest: /var/www/app/
  notify: deploy web stack

- name: Update backend config
  template:
    src: api.conf.j2
    dest: /etc/api/config.yml
  notify: deploy web stack
```

---

# Handlers: `listen` — use cases (continued)

```yaml
handlers:
  - name: restart nginx
    service: name=nginx state=restarted
    listen: deploy web stack

  - name: restart api
    service: name=api state=restarted
    listen: deploy web stack

  - name: clear cache
    redis: command=flush_db
    listen: deploy web stack

  - name: notify team
    slack: msg="Deploy completed on {{ inventory_hostname }}"
    listen: deploy web stack
```

**🎯 Outcome**: any change triggers the full “web stack”

---

# Handlers: `meta: flush_handlers`

### Run notified handlers **now**

**Default**: handlers run at the **end** of the play

**Sometimes**: you need a handler **before** the next task

```yaml
tasks:
  - name: Update nginx config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: restart nginx

  - name: Flush handlers now
    meta: flush_handlers

  - name: Check nginx responds
    uri:
      url: http://localhost
      status_code: 200
```

---

# Handlers: `flush_handlers` — use cases

### When to flush

**✅ Typical cases**:

1. **Immediate check** after restart
   ```yaml
   - template: ...
     notify: restart nginx
   - meta: flush_handlers
   - uri: url=http://localhost  # nginx already restarted
   ```

2. **Task ordering / dependency**
   ```yaml
   - copy: src=cert.pem dest=/etc/ssl/
     notify: reload nginx
   - meta: flush_handlers
   - command: curl --cert /etc/ssl/cert.pem https://api  # needs reload first
   ```

---

# Handlers: `flush_handlers` — use cases (continued)

3. **Reboot before later tasks**
   ```yaml
   - name: Update kernel
     apt: name=linux-image-generic state=latest
     notify: reboot server
   
   - meta: flush_handlers  # reboot NOW
   
   - name: Install app (on new kernel)
     apt: name=myapp state=present
   ```

**⚠️ Watch out**: `flush_handlers` runs **all** handlers notified so far!

---

# Chained handlers

### One handler notifies another

**Use case**: ordered side effects

```yaml
tasks:
  - name: Update app code
    git:
      repo: https://github.com/user/app.git
      dest: /opt/app
    notify: rebuild app

handlers:
  - name: rebuild app
    command: npm run build
    args:
      chdir: /opt/app
    notify: restart app  # handler notifies another handler

  - name: restart app
    service:
      name: myapp
      state: restarted
    notify: notify team  # chain continues

  - name: notify team
    slack:
      msg: "App restarted on {{ inventory_hostname }}"
```

---

# Chained handlers: execution order

### How ordering works

**Order** follows the **declaration order** in `handlers:`

```yaml
# From the previous example:
# 1. rebuild app
# 2. restart app  
# 3. notify team

# ⚠️ NOT the order of notify strings — declaration order in handlers:!
```

**💡 Tip**: list handlers in the order you want them to run

---

# Handlers: everyday examples

### Real case 1: web app deploy

```yaml
tasks:
  - name: Update app code
    git:
      repo: https://github.com/company/webapp.git
      dest: /var/www/app
      version: "{{ app_version }}"
    notify:
      - build frontend
      - restart backend

handlers:
  - name: build frontend
    command: npm run build
    args:
      chdir: /var/www/app

  - name: restart backend
    service:
      name: webapp-api
      state: restarted
```

💡 **Note**: use `service` for Docker compatibility

---

# Handlers: everyday examples (2)

### Real case 2: SSL/TLS

```yaml
tasks:
  - name: Deploy SSL certificate
    copy:
      src: "{{ item }}"
      dest: "/etc/nginx/ssl/"
    loop:
      - cert.pem
      - key.pem
      - ca-bundle.crt
    notify:
      - validate nginx config
      - reload nginx

handlers:
  - name: validate nginx config
    command: nginx -t
    listen: validate nginx config

  - name: reload nginx
    service:
      name: nginx
      state: reloaded
    listen: reload nginx
```

---

# Handlers: everyday examples (3)

### Real case 3: database migrations

```yaml
tasks:
  - name: Deploy database migrations
    copy:
      src: migrations/
      dest: /opt/app/migrations/
    notify: run migrations

  - name: Update app config
    template:
      src: database.yml.j2
      dest: /etc/app/database.yml
    notify: restart app after db update

handlers:
  - name: run migrations
    command: /opt/app/bin/migrate
    environment:
      DB_HOST: "{{ db_host }}"
    notify: restart app after db update

  - name: restart app after db update
    service:
      name: webapp
      state: restarted
```

💡 **Note**: use `service` for Docker compatibility

---

# Handlers: everyday examples (4)

### Real case 4: monitoring and alerts

```yaml
tasks:
  - name: Update monitoring config
    template:
      src: prometheus.yml.j2
      dest: /etc/prometheus/prometheus.yml
    notify: monitoring stack reload

handlers:
  - name: reload prometheus
    service:
      name: prometheus
      state: reloaded
    listen: monitoring stack reload

  - name: reload alertmanager
    service:
      name: alertmanager
      state: reloaded
    listen: monitoring stack reload

  - name: validate alerts
    command: amtool check-config /etc/alertmanager/config.yml
    listen: monitoring stack reload
```

💡 **Note**: use `service` for Docker compatibility

---

# Handlers: everyday examples (5)

### Real case 5: backup before change

```yaml
tasks:
  - name: Backup current config
    copy:
      src: /etc/nginx/nginx.conf
      dest: "/backup/nginx.conf.{{ ansible_date_time.epoch }}"
      remote_src: yes

  - name: Deploy new config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify:
      - validate nginx
      - reload nginx safe

handlers:
  - name: validate nginx
    command: nginx -t
    register: nginx_test
    failed_when: nginx_test.rc != 0

  - name: reload nginx safe
    service:
      name: nginx
      state: reloaded
```

---

# Handlers: debugging

### See which handlers were notified

**Verbose**:

```bash
ansible-playbook site.yml -v

# Output :
# TASK [Update config] ***
# changed: [web01]
# => notify: ['restart nginx', 'send notification']
```

**Extra verbose**:

```bash
ansible-playbook site.yml -vvv

# Shows:
# - when handlers are notified
# - when handlers run
# - each handler result
```

---

# Handlers: debugging (continued)

### Notified but never ran?

**Debug checklist**:

```bash
# 1. Exact name match
ansible-playbook site.yml -v | grep "notify:"

# 2. Did the task change anything?
ansible-playbook site.yml -v | grep "changed:"

# 3. Force handlers on failure
ansible-playbook site.yml --force-handlers

# 4. Flush for testing — temporarily in playbook:
- meta: flush_handlers
- debug: msg="Handler should have run by now"
```

---

# Handlers: detailed execution order

### How ordering works

**Scenario**:

```yaml
tasks:
  - name: Task A
    copy: ...
    notify: handler 2

  - name: Task B
    template: ...
    notify: handler 1

  - name: Task C
    file: ...
    notify: handler 2
```

**Question**: in what order do handlers run?

---

# Handlers: detailed execution order (continued)

```yaml
handlers:
  - name: handler 1
    debug: msg="Handler 1"

  - name: handler 2
    debug: msg="Handler 2"

  - name: handler 3
    debug: msg="Handler 3"
```

**Answer**:
1. **handler 1** (listed first under `handlers:`)
2. **handler 2** (second in file, notified twice but runs once)

**⚠️ Rule**: order = **declaration** order in `handlers:`, not notify order!

---

# Handlers with `when` (condition)

### Conditional handlers

```yaml
tasks:
  - name: Update app
    copy:
      src: app.jar
      dest: /opt/app/
    notify: restart app

handlers:
  - name: restart app
    service:
      name: myapp
      state: restarted
    when: env == "production"
```

💡 **Note**: use `service` for Docker compatibility

**💡 Behavior**:
- notified → queued
- runs → only if `when:` evaluates true

---

# Handlers with `when` — examples

### Practical patterns

```yaml
handlers:
  # restart only in production
  - name: restart nginx
    service: name=nginx state=restarted
    when: env == "production"

  # notify only at night
  - name: send slack alert
    slack: msg="Deployment completed"
    when: ansible_date_time.hour | int > 20 or ansible_date_time.hour | int < 8

  # only on hosts with enough RAM
  - name: clear cache
    command: redis-cli FLUSHALL
    when: ansible_facts['memtotal_mb'] > 4096
```

---

# Recap: handlers — core concepts

### What to remember

**1. What is a handler?**
- Runs **only** if notified **and** the task changed something
- Runs at **end** of play (unless `flush_handlers`)
- Notified many times → still **one** run per play (unless flushed)

**2. When to use?**
- reactive work (restart, reload, rebuild…)
- many tasks should trigger the **same** action
- work can wait until handler phase

**3. Syntax**:
- `notify: handler_name` on the task
- **Exact** `name:` under `handlers:`

---

# Recap: handlers — advanced bits

### Techniques worth knowing

**1. `listen`**: group several handlers

```yaml
notify: deploy web stack
handlers:
  - name: restart nginx
    listen: deploy web stack
  - name: restart app
    listen: deploy web stack
```

**2. `flush_handlers`**: run immediately

```yaml
- notify: restart nginx
- meta: flush_handlers
- uri: url=http://localhost  # nginx already restarted before this
```

---

# Recap: handlers — advanced bits (2)

**3. Chains**: handler notifies another

```yaml
handlers:
  - name: build app
    command: npm run build
    notify: restart app
  
  - name: restart app
    service: name=app state=restarted
```

**4. Multiple notify**: several handlers at once

```yaml
notify:
  - restart nginx
  - reload haproxy
  - clear cache
```

---

# Handlers cheat sheet

### Quick syntax

```yaml
# basic
tasks:
  - template: src=app.conf.j2 dest=/etc/app.conf
    notify: restart app

handlers:
  - name: restart app
    service: name=app state=restarted

# with listen (group)
tasks:
  - template: ...
    notify: update stack

handlers:
  - name: restart nginx
    listen: update stack
  - name: restart app
    listen: update stack

# with flush_handlers (immediate)
tasks:
  - template: ...
    notify: restart app
  - meta: flush_handlers
  - uri: url=http://localhost
```

---

# Decision tree: handler or normal task?

### Which mechanism?

```
Do you need to run an action?
│
├─ Must it ALWAYS run?
│  └─ ✅ normal task
│
├─ Need the result immediately (register)?
│  └─ ✅ normal task
│
├─ Is strict ordering critical (no deferral)?
│  └─ ✅ normal task (or handler + flush_handlers)
│
└─ Should it run ONLY if something changed?
   ├─ Is it a reaction (restart, reload, notify…)?
   │  └─ ✅ handler
   │
   └─ Can several tasks trigger the same action?
      └─ ✅ handler (optionally with `listen` to group)
```

---

# ❌ Common mistakes: handlers recap

### Traps to avoid

**1. Mismatched notify / handler name**

```yaml
# ❌ BAD
notify: restart nginx
handlers:
  - name: Restart nginx  # different case!
```

**2. Using a handler when you need immediate work**

```yaml
# ❌ BAD
- command: service nginx stop
  notify: start nginx
- uri: url=http://localhost  # ❌ nginx not up yet!

# ✅ GOOD
- command: service nginx stop
  notify: start nginx
- meta: flush_handlers
- uri: url=http://localhost  # ✅ nginx started first
```

💡 **Docker note**: in containers prefer `service` over `systemctl`

---

# ❌ Common mistakes: handlers recap (2)

**3. Handler for work that must always run**

```yaml
# ❌ BAD
tasks:
  - debug: msg="Starting deployment"
    notify: send start notification

# ✅ GOOD
tasks:
  - name: Send start notification
    slack: msg="Starting deployment"
  
  - debug: msg="Starting deployment"
```

**4. Forgetting a handler runs once even if notified many times**

```yaml
# restart nginx notified 5× → still runs once at end
# by design (idempotency)
```

---

# Checklist: debugging handlers

### Handler never fires?

**✅ Check in order**:

1. **Exact name match?**
   ```bash
   grep -n "notify:" playbook.yml
   grep -n "name:" playbook.yml | grep handler
   ```

2. **Did the task change anything?**
   ```bash
   ansible-playbook site.yml -v | grep "changed:"
   ```

3. **Handler defined?**
   ```bash
   ansible-playbook site.yml --syntax-check
   ```

4. **Play finished without fatal errors?**
   ```bash
   ansible-playbook site.yml --force-handlers  # to experiment
   ```

---

# Going further: handlers

### Advanced patterns

**1. Handler with `delegate_to`**

```yaml
handlers:
  - name: update load balancer
    uri:
      url: "http://{{ item }}:8080/reload"
    delegate_to: localhost
    with_items: "{{ groups['load_balancers'] }}"
```

**2. Handler with `serial` (rolling deploy)**

```yaml
- hosts: webservers
  serial: 1  # one host at a time
  tasks:
    - template: ...
      notify: restart nginx
  
  handlers:
    - name: restart nginx
      service: name=nginx state=restarted
  # each host restarts before moving to the next
```

---

# 📚 Official docs: handlers

### Resources

**Ansible docs**:
- Handlers: [docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html)
- meta: flush_handlers: [docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html)

**Examples**:
- Ansible Galaxy: [galaxy.ansible.com](https://galaxy.ansible.com)
- GitHub: search “ansible handlers” for real-world snippets

---

# 🎯 Mini exercise: Module 10 (10 min)

**Goal**: wire up a working handler

```yaml
# playbook-handler.yml:
tasks:
  - name: Create config file
    copy:
      content: "test config"
      dest: /tmp/app.conf
    notify: show message

handlers:
  - name: show message
    debug:
      msg: "Config changed!"
```

**Test**: run twice — handler should run only the first time.

---
layout: new-section
routeAlias: 'collections'
---

<a name="collections" id="collections"></a>

# Module 12: collections

---

# What is a collection? 🌐

### Specialized add-ons

A **collection** is a packaged extension for Ansible:

- 📦 **Bundle**: specialized modules together

- 🌍 **Domains**: cloud (AWS, Azure), containers (Docker), orchestration (Kubernetes)

- 🔄 **Lifecycle**: updates ship separately from Ansible core

- 🎯 **Focus**: expert tooling per technology

**Analogy**: browser extensions for extra capabilities.

---

# Collections and the ecosystem 🌐

### Must-have examples

```bash
# Collections Docker
ansible-galaxy collection install community.docker

# Collections Cloud
ansible-galaxy collection install amazon.aws
ansible-galaxy collection install azure.azcollection

# Collections Kubernetes
ansible-galaxy collection install kubernetes.core
```

---

# Collections: requirements.yml

### Same dependencies for the whole team / CI

```yaml
# requirements.yml (repo root for your Ansible project)
collections:
  - name: community.docker
    version: ">=3.4.0"
  - name: amazon.aws
    version: ">=8.0.0"
```

---

# Collections: install from requirements.yml

```bash
ansible-galaxy collection install -r requirements.yml
# force refresh (e.g. CI)
ansible-galaxy collection install -r requirements.yml --force
```

---

# Collections: paths and resolution

### Where Ansible finds them

- **`ansible-galaxy collection list`**: what your install can see
- **`ansible.cfg`**: `collections_paths` to add a project dir (e.g. `./collections`)

```ini
[defaults]
collections_paths = ~/.ansible/collections:./collections
```

---

# FQCN et ansible.builtin

### Fully qualified names (recommended in 2026)

- **FQCN**: `namespace.collection.module` — no ambiguity across collections
- **`ansible.builtin`**: core modules (`copy`, `file`, `service`, …); FQCN example: `ansible.builtin.copy`
- **Docs**: `ansible-doc -t module community.docker.docker_container`

Collections can ship **plugins** too (Jinja filters, lookups), not only modules.

---

# Using collections

```yaml
# Example: cloud module (fake AMI — adapt to your region/account)
- name: Cloud infra + containers
  hosts: localhost
  tasks:
    - name: Create AWS instance
      amazon.aws.ec2_instance:
        name: docker-host
        image_id: ami-0abcdef1234567890
        instance_type: t3.medium
```

---

# Collections: wait for SSH then Docker (sketch)

```yaml
- name: Wait for SSH on the instance
  ansible.builtin.wait_for:
    host: "{{ item.public_ip_address }}"
    port: 22
    timeout: 300

- name: Deploy container on remote host
  community.docker.docker_container:
    name: myapp
    image: nginx:alpine
  delegate_to: "{{ item.public_ip_address }}"
```

---

# ✅ Namespaced modules (collections)

### Understanding `community.docker.docker_container`

**Format**: `namespace.collection.module` — here `community` · `docker` · `docker_container`

```yaml
- name: Run a container
  community.docker.docker_container:
    name: webapp
    image: nginx
    state: started
```

---

# Why namespaces?

### Organizing thousands of modules

**Before (Ansible &lt; 2.10)**: one big bundle — short names.

```yaml
- docker_container:  # deprecated / not resolved without redirection
```

---

# Why namespaces? (continued)

**Since Ansible 2.10+**: modules ship in **collections** — independent of core releases.

```yaml
- community.docker.docker_container:
    name: webapp
```

---

# ❌ Common mistake: module without FQCN

```yaml
- name: Run container
  docker_container:  # ERROR: not resolved without collection / FQCN
    name: webapp
```

---

# ❌ Typical Ansible error

```
ERROR! couldn't resolve module/action 'docker_container'
```

---

# ✅ Fix 1: FQCN (collection already installed)

```yaml
- community.docker.docker_container:
    name: webapp
```

---

# ✅ Fix 2: install the collection

```bash
ansible-galaxy collection install community.docker
```

---

# ✅ Fix 2 (continued): playbook

```yaml
- name: Run container
  community.docker.docker_container:
    name: webapp
```

---

# Common collections

| Collection | Modules | Install |
|------------|---------|---------|
| `community.docker` | Docker/containers | `ansible-galaxy collection install community.docker` |
| `community.general` | misc utilities | Often bundled; else `ansible-galaxy collection install community.general` |
| `ansible.posix` | Linux/POSIX | Often bundled with the Ansible package |
| `amazon.aws` | AWS | `ansible-galaxy collection install amazon.aws` |
| `kubernetes.core` | Kubernetes | `ansible-galaxy collection install kubernetes.core` |

---

# 🧠 Collections: rule of thumb

> **If the module name contains a dot (`.`), it comes from a collection**

Prefer the full name: `namespace.collection.module`

---

# Collections: roles shipped inside a collection

### Same Galaxy mechanism; ship modules **and** roles under one version

A collection may embed **roles** referenced like this:

```yaml
roles:
  - namespace.collection.role_name
```

---

# ✅ Mini quiz: Module 12 — collections

**Question 1**: what is an Ansible collection?
- A) a group of servers
- B) a pack of specialized modules
- C) a playbook type

**Question 2**: how do you install a collection?
- A) `ansible install community.docker`
- B) `ansible-galaxy collection install community.docker`
- C) `pip install ansible-collection-docker`

**Question 3**: `community.docker.docker_container` means:
- A) community = namespace, docker = collection, docker_container = module
- B) just a long module name
- C) community.docker is obsolete

---

# 📝 Mini quiz answers — Module 12

**Question 1**: **B** ✅  
A collection bundles specialized modules (e.g. `community.docker` for Docker, `amazon.aws` for AWS).

**Question 2**: **B** ✅  
Command: `ansible-galaxy collection install namespace.collection`. Galaxy manages collections and roles.

**Question 3**: **A** ✅  
Pattern: `namespace.collection.module`. Example: `community.docker.docker_container`.

---

# 🎯 Mini exercise: Module 12 (5 min)

### Goal: install and use a collection

```bash
# 1. Install
ansible-galaxy collection install community.general

# 2. List installed collections
ansible-galaxy collection list

# 3. Run a module from the collection
ansible localhost -m community.general.timezone -a "name=UTC" --become
```

---

# 🎯 Mini exercise: Module 12 (check)

**Expected**: the collection shows in `ansible-galaxy collection list`; `timezone` runs clean (on some OSes you need `--become`).

---
layout: new-section
routeAlias: 'vault'
---

<a name="vault" id="vault"></a>

# Module 13: Ansible Vault

---

# What is Ansible Vault? 🔐

### A safe for your secrets

**Ansible Vault** encrypts sensitive data:

- 🔒 **Encryption**: passwords, API keys, certificates

- 🔑 **Master password**: one secret to decrypt vault files

- 📁 **Encrypted files**: secrets stored encrypted in the repo

- 👥 **Team workflow**: run playbooks without plaintext secrets in working copies

**Analogy**: a password manager for your automation.

---

# Ansible Vault: secrets 🔐

### Managing secrets safely

```bash
# create or edit a fully encrypted file
ansible-vault create secrets.yml
ansible-vault edit secrets.yml

# encrypt / view / run playbooks (2.20+: --encrypt-vault-id default if prompted)
ansible-vault encrypt secrets.yml --encrypt-vault-id default
ansible-vault view secrets.yml
ansible-playbook -i inventory deploy.yml --ask-vault-pass
# modern equivalent (interactive password):
ansible-playbook -i inventory deploy.yml --vault-id default@prompt
```

---

# Vault: using secrets

### Load encrypted content into playbooks

Several patterns work with vault-encrypted files.

---

# Vault: method 1 — `vars_files` in the playbook

### Merge encrypted vars at play scope

Files listed in **`vars_files`** merge into the **play**: keys like `vault_db_password` are visible to all tasks (paths are **relative to the playbook** unless you use `@` or absolute paths).

```yaml
# playbook-deploy.yml
---
- name: Deploy with secrets
  hosts: webservers
  become: true
  vars_files:
    - secrets.yml

  tasks:
    - name: Configure database
      template:
        src: database.conf.j2
        dest: /etc/app/database.conf

    - name: Configure API
      template:
        src: api.conf.j2
        dest: /etc/app/api.conf
```

Templates `database.conf.j2` / `api.conf.j2` can use `{{ vault_db_password }}`, `{{ vault_api_key }}`, etc.

---

# Vault: method 1 — `vars_files` (continued)

### Example `secrets.yml` (then encrypt)

```yaml
# secrets.yml (encrypt with ansible-vault)
---
vault_db_password: "P@ssw0rd_SuperSecret_2026!"
vault_api_key: "ak_1234567890abcdef_ghijklmnop"
vault_smtp_password: "smtp_secret_password"
vault_jwt_secret: "jwt_random_secret_key_xyz"
```

### Create and encrypt the file

```bash
# 1. create secrets.yml with the values above
nano secrets.yml

# 2. encrypt (2.20+: --encrypt-vault-id default if Ansible asks)
ansible-vault encrypt secrets.yml --encrypt-vault-id default
# enter vault password (or use --vault-password-file)

# 3. run the playbook
ansible-playbook playbook-deploy.yml --ask-vault-pass
```

---

# Vault: method 2 — group_vars

### Auto-load via `group_vars`

**Recommended layout** (secrets for the **whole** inventory):

```
ansible-project/
├── playbook.yml
├── inventory.yml
└── group_vars/
    └── all/
        ├── public.yml       # plaintext (references vault_*)
        └── vault.yml        # encrypted secrets (merged into group `all`)
```

**Gotcha 1**: `group_vars/vault.yml` does **not** apply to all hosts — only hosts in an inventory group literally named `vault`. Hence **`group_vars/all/`**.

**Gotcha 2 (tested on Ansible 2.20+)**: do **not** keep **`group_vars/all.yml`** (file) **and** the **`group_vars/all/`** directory together. The top-level **`all.yml` is then ignored**: you only load YAML from the directory — often the `vault_*` keys without the `db_password: "{{ vault_db_password }}"` lines that lived in the ignored file.

---

# Vault: method 2 — group_vars (continued)

**`group_vars/all/public.yml`** (plaintext, safe in Git)

```yaml
---
# Public vars referencing secrets
db_host: "db.example.com"
db_port: 5432
db_user: "app_user"
db_password: "{{ vault_db_password }}"  # ← secret reference

api_url: "https://api.example.com"
api_key: "{{ vault_api_key }}"  # ← secret reference

# Non-sensitive settings
app_version: "v2.1.0"
app_port: 8080
```

---

# Vault: method 2 — group_vars (continued 2)

**`group_vars/all/vault.yml`** (encrypt with `ansible-vault encrypt` — next slide for Ansible 2.20+)

```yaml
---
# BEFORE encryption (teaching sample — never commit plaintext)
vault_db_password: "P@ssw0rd_SuperSecret_2026!"
vault_api_key: "ak_1234567890abcdef_ghijklmnop"
vault_smtp_password: "smtp_secret_password"
vault_jwt_secret: "jwt_random_secret_key_xyz"
```

**Minimal playbook**:

```yaml
# playbook.yml
---
- name: Deploy
  hosts: webservers
  tasks:
    - ansible.builtin.debug:
        msg: "DB Password: {{ db_password }}"
```

**Benefit**: no `vars_files`; Ansible loads **all `*.yml`** under **`group_vars/all/`** for hosts in group `all`.

---

# Vault: Ansible 2.20+ — encrypt and vault-id

If `ansible-vault encrypt` lists several **vault-id** values, pick one (often `default`):

```bash
ansible-vault encrypt group_vars/all/vault.yml \
  --vault-password-file .vault_pass \
  --encrypt-vault-id default
```

Same for `ansible-vault create` / `rekey` when Ansible asks.

---

# Vault: method 3 — password file

### Skip `--ask-vault-pass` every time

```bash
# 1. create vault password file
echo "my_super_secret_vault_password" > .vault_pass

# 2. lock down permissions
chmod 600 .vault_pass

# 3. gitignore it
echo ".vault_pass" >> .gitignore

# 4. pass to playbook
ansible-playbook playbook.yml --vault-password-file .vault_pass
```

**Or in ansible.cfg**:

```ini
[defaults]
vault_password_file = .vault_pass
```

Then you do not pass the password each run:

```bash
ansible-playbook playbook.yml  # ← decrypts automatically
```

---

# Vault: end-to-end example

### Full workflow

```bash
# 1. layout (under group_vars/all/ — no parallel group_vars/all.yml file)
mkdir -p group_vars/all templates
```

---

# Vault: full example (continued)

```bash
# 2. public vars (same folder as vault)
cat > group_vars/all/public.yml << 'EOF'
---
db_host: "localhost"
db_user: "app_user"
db_password: "{{ vault_db_password }}"
api_key: "{{ vault_api_key }}"
EOF

# 3. secrets for whole inventory
cat > group_vars/all/vault.yml << 'EOF'
---
vault_db_password: "P@ssw0rd_2026"
vault_api_key: "secret_key_xyz"
EOF

# 4. encrypt (password prompt; 2.20+: --encrypt-vault-id default if asked)
ansible-vault encrypt group_vars/all/vault.yml --encrypt-vault-id default
```

---

# Vault: full example (continued 2)

```bash
# 5. template using secrets
cat > templates/config.j2 << 'EOF'
[database]
host={{ db_host }}
user={{ db_user }}
password={{ db_password }}

[api]
key={{ api_key }}
EOF

# 6. playbook
cat > playbook.yml << 'EOF'
---
- name: Deploy with secrets
  hosts: localhost
  tasks:
    - name: Render config
      template:
        src: config.j2
        dest: /tmp/app.conf
EOF
```

---

# Vault: full example (continued 3)

```bash
# 7. run (vault password at prompt)
ansible-playbook playbook.yml --ask-vault-pass
# or: ansible-playbook playbook.yml --vault-id default@prompt

# 8. verify
cat /tmp/app.conf
# shows:
# [database]
# host=localhost
# user=app_user
# password=P@ssw0rd_2026
#
# [api]
# key=secret_key_xyz
```

**✅ Secrets decrypt automatically at runtime!**

---

# Vault: three patterns compared

### When to use which

| Pattern | Pros | Cons | Typical use |
|---------|------|------|-------------|
| **vars_files** | explicit | repeat per playbook | one-off playbook secrets |
| **group_vars/all/** | automatic for all hosts | **`public.yml` + `vault.yml`** in `all/`; no **`all.yml` file** next to **`all/`** dir; not `group_vars/vault.yml` for “everyone” | shared secrets (**recommended**) |
| **vault-password-file** | no typing | protect the file | CI/CD |

**Recommendation**: **`group_vars/all/`** (public + encrypted vault) for most projects.

---

# ✅ Vault: naming convention

### Why prefix with `vault_`?

```yaml
# secrets.yml (encrypted)
vault_db_password: 'super_secret_password'  # ✅ prefixed
vault_api_key: '1234567890abcdef'  # ✅ prefixed
```

**Not required — just a good habit.**

---

# Vault: why this convention?

### Traceability and safety

```yaml
# group_vars/all/public.yml (plaintext in Git)
db_password: '{{ vault_db_password }}'
api_key: '{{ vault_api_key }}'

# group_vars/all/vault.yml (ansible-vault encrypted)
vault_db_password: 'the_real_secret'
vault_api_key: 'the_real_key'
```

**Benefit**: plaintext shows the value is resolved from vault material.

---

# ❌ Without a convention: confusion risk

```yaml
# same plaintext file = BAD
db_password: 'super_secret'  # ⚠️ secret in Git!
api_key: 'my_api_key'  # ⚠️ exposed!
```

```yaml
# with vault_* prefix: clearer
db_password: '{{ vault_db_password }}'  # ✅ resolved from encrypted store
api_key: '{{ vault_api_key }}'  # ✅ resolved from encrypted store
```

---

# 🧠 Vault: rule of thumb

> **`vault_` prefix = convention, not a hard requirement**

**It still helps to:**
- 🔍 spot secrets quickly
- 🛡️ avoid committing plaintext secrets
- 📖 keep team-readable indirections

---

# ✅ Mini quiz: Module 13 — Ansible Vault

**Question 1**: what is Vault for?
- A) store playbooks securely
- B) encrypt sensitive data like passwords
- C) automatic backups

**Question 2**: how do you create an encrypted file?
- A) `ansible-vault encrypt file.yml`
- B) `ansible-vault create file.yml`
- C) both work

**Question 3**: why prefix variables with `vault_`?
- A) technically mandatory
- B) good practice to mark secrets
- C) Ansible requires it

---

# 📝 Mini quiz answers — Module 13

**Question 1**: **B** ✅  
Vault encrypts sensitive values (passwords, API keys, certs). Files can live in Git **encrypted**.

**Question 2**: **C** ✅  
`create` makes a new encrypted file. `encrypt` wraps an existing file. Both are valid.

**Question 3**: **B** ✅  
`vault_` prefix = convention (not mandatory). Makes vault-sourced vars obvious.

**Gotchas**: global secrets → **`group_vars/all/vault.yml`**, not `group_vars/vault.yml` (that targets inventory group `vault`). Do not mix **`group_vars/all.yml`** with **`group_vars/all/`** dir (file ignored on Ansible 2.20).

---

# 🎯 Mini exercise: Module 13 (10 min)

### Goal: create and use an encrypted secret

```bash
ansible-vault create secrets.yml
# in the editor, for example:
# ---
# vault_api_key: "secret123"
```

---

# 🎯 Mini exercise: Module 13 (continued)

**`playbook-vault-demo.yml`** (same directory as `secrets.yml` for `vars_files`)

```yaml
---
- hosts: localhost
  vars_files:
    - secrets.yml
  tasks:
    - ansible.builtin.debug:
        msg: "API Key: {{ vault_api_key }}"
```

---

# 🎯 Mini exercise: Module 13 (run)

```bash
ansible-playbook playbook-vault-demo.yml --ask-vault-pass
# or: ansible-playbook playbook-vault-demo.yml --vault-id default@prompt
```

---
layout: new-section
routeAlias: 'debugging'
---

<a name="debugging" id="debugging"></a>

# Module 13.5: debugging and troubleshooting

---

# Why debug? 🐛

### Errors are normal

**Reality**: experienced Ansible users still break things.

**Common issues**:
- bad YAML
- undefined variables
- missing permissions
- missing modules / collections
- SSH failures

**Goal**: find and fix fast.

---

# Verbose mode: -v, -vv, -vvv 📢

### More detail → easier debugging

```bash
# level 1: basic
ansible-playbook playbook.yml -v

# level 2: more detail
ansible-playbook playbook.yml -vv

# level 3: very verbose
ansible-playbook playbook.yml -vvv

# level 4: SSH debug
ansible-playbook playbook.yml -vvvv
```

**Use**:
- `-v`: task outcomes
- `-vv`: module details
- `-vvv`: commands Ansible runs
- `-vvvv`: deep SSH tracing

---

# The debug module: print variables 💡

### Your best friend while troubleshooting

```yaml
# print one variable
- debug:
    var: ansible_hostname

# formatted message
- debug:
    msg: "App: {{ app_name }}, Version: {{ app_version }}"

# all vars for this host
- debug:
    var: hostvars[inventory_hostname]

# output from a previous task
- debug:
    var: result.stdout
```

**💡 Tip**: use `debug` to validate values before risky tasks!

---

# Dry-run mode: --check 🎯

### Test without changing anything

```bash
# simulate a run with no changes
ansible-playbook playbook.yml --check

# combine with diff to preview changes
ansible-playbook playbook.yml --check --diff

# dry-run on one host
ansible-playbook playbook.yml --limit web-01 --check
```

**Benefits**:
- ✅ see what would change before doing it
- ✅ rehearse against prod inventory safely (no writes)
- ✅ validate playbook logic

**⚠️ Note**: some modules do not support `--check`

---

# Resume from a task: --start-at-task 🔄

### Avoid replaying from the top

```bash
# resume at a named task
ansible-playbook playbook.yml --start-at-task="Install nginx"

# handy after a failure
# 1. fix the issue
# 2. restart from the task that failed
```

---

# Step-by-step: --step ⏯️

### Full control over execution

```bash
# confirm before each task
ansible-playbook playbook.yml --step
```

**Flow**:
1. Ansible shows the next task
2. You pick: (y)es, (n)o, (c)ontinue
3. Great for complex playbooks

---

# Limit scope: --limit 🎯

### Run on a subset of hosts

```bash
# one host
ansible-playbook playbook.yml --limit web-01

# one group
ansible-playbook playbook.yml --limit webservers

# several hosts
ansible-playbook playbook.yml --limit "web-01,web-02"

# exclude hosts
ansible-playbook playbook.yml --limit "all:!db-01"
```

**Use case**: try one server before rolling out everywhere.

---

# Tags for selective runs 🏷️

### Run only part of a playbook

```yaml
tasks:
  - name: Install packages
    apt: name=nginx
    tags: [install, packages]

  - name: Configure nginx
    template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf
    tags: [config]

  - name: Start nginx
    service: name=nginx state=started
    tags: [service, start]
```

```bash
# only tasks tagged config
ansible-playbook playbook.yml --tags config

# everything except install
ansible-playbook playbook.yml --skip-tags install

# list tags
ansible-playbook playbook.yml --list-tags
```

---

# Common errors and fixes 🔧

### Typical traps

**Error 1**: `Module not found: docker_container`
```bash
# fix: install the collection
ansible-galaxy collection install community.docker
```

**Error 2**: `Permission denied`
```yaml
# fix: enable privilege escalation
- hosts: web
  become: true  # ← add this
```

**Error 3**: `Unable to connect to host`
```bash
# fix: check SSH
ansible web-01 -m ping
ssh ubuntu@web-01
```

---

# Common errors (continued) 🔧

**Error 4**: `Undefined variable: app_version`
```yaml
# fix: spelling + define the variable
vars:
  app_version: "1.0.0"  # ← define it
```

**Error 5**: `YAML syntax error`
```yaml
# ❌ bad indentation
tasks:
- name: Install nginx
  apt:
  name: nginx  # ← wrong level

# ✅ correct
tasks:
  - name: Install nginx
    apt:
      name: nginx  # ← nested under apt
```

---

# Debugging strategy 🎯

### Work systematically

**1. Read the error carefully**
- the message often hints at the fix
- note the line number

**2. Validate YAML**
```bash
ansible-playbook playbook.yml --syntax-check
```

**3. Try localhost first**
```yaml
- hosts: localhost
  connection: local  # ← no SSH
```

**4. Layer debug tasks**
```yaml
- debug: var=my_var
- debug: msg="Before the failing task"
- name: Task under investigation
  ...
- debug: msg="After the task"
```

---

# Useful commands 🛠️

### Diagnostics

```bash
# YAML syntax
ansible-playbook playbook.yml --syntax-check

# list tasks without running
ansible-playbook playbook.yml --list-tasks

# list targeted hosts
ansible-playbook playbook.yml --list-hosts

# active Ansible config
ansible-config dump

# connectivity
ansible all -m ping -i inventory.yml

# facts for one host
ansible web-01 -m setup
```

---

# 🎯 Debugging checklist

**Before asking for help, check**:

- [ ] YAML is valid (`--syntax-check`)
- [ ] variables exist (add `debug`)
- [ ] inventory is right (`--list-hosts`)
- [ ] SSH works (`ansible host -m ping`)
- [ ] privileges (`become: true`?)
- [ ] modules/collections installed
- [ ] more detail with `-vvv`

**Most issues clear with the steps above!**

---
layout: new-section
routeAlias: 'bonnes-pratiques'
---

<a name="bonnes-pratiques" id="bonnes-pratiques"></a>

# Module 14: optimization and best practices (bonus)

---

# Optimization and best practices 🚀

### Production-oriented `ansible.cfg`

```ini
# ansible.cfg
[defaults]
# skip SSH host key prompts (lab only — tighten for prod)
host_key_checking = False
# show per-task timing
callback_whitelist = timer, profile_tasks
# readable task output
stdout_callback = yaml
# parallel forks
forks = 20
# SSH timeout
timeout = 60
```

---

# Project layout

```
ansible-project/
├── ansible.cfg
├── inventory/
│   ├── production.yml
│   └── staging.yml
├── group_vars/
│   ├── all.yml
│   ├── docker.yml
│   └── webapp.yml
├── templates/
│   ├── nginx.conf.j2
│   ├── docker-compose.yml.j2
│   ├── daemon.json.j2
│   ├── .env.j2
│   └── README.md
├── playbooks/
│   ├── site.yml
│   └── deploy.yml
├── roles/
│   ├── docker/
│   ├── nginx/
│   └── app/
├── .env
├── .env.staging
├── .env.production
├── .env.development
└── secrets.yml (vault)
```
