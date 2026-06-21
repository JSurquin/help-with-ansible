# Essential commands — Ansible exercise solution

## 🚀 Quick start

```bash
# 1. Start the infrastructure
docker-compose up -d

# 2. Deploy Apache2
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml

# 3. Deploy Nginx
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml

# 4. Run all automated tests
./test.sh
```

## 📋 Detailed commands

### Docker management

```bash
# Start containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose stop

# Stop and remove
docker-compose down

# List containers
docker ps

# Enter a container
docker exec -it apache-server-1 bash
docker exec -it nginx-server-1 bash
```

### Ansible — Inventories

```bash
# List all Apache hosts
ansible -i inventories/apache2.yml all --list-hosts

# List all Nginx hosts
ansible -i inventories/nginx.yml all --list-hosts

# Show inventory in detail
ansible-inventory -i inventories/apache2.yml --list
ansible-inventory -i inventories/nginx.yml --graph
```

### Ansible — Connectivity tests

```bash
# Ping all Apache servers
ansible -i inventories/apache2.yml all -m ping

# Ping all Nginx servers
ansible -i inventories/nginx.yml all -m ping

# Run an ad-hoc command
ansible -i inventories/apache2.yml all -m command -a "hostname"
```

### Ansible — Playbook execution

```bash
# Normal mode
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml

# Check mode (dry-run, makes no changes)
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml --check

# Diff mode (shows changes)
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml --diff

# Verbose mode (-v, -vv, -vvv, -vvvv)
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml -v
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml -vvv

# Target a single host
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml --limit apache1

# Start from a specific task
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml --start-at-task="Install Nginx"
```

### Ansible — Variables

```bash
# Show all variables for a host
ansible -i inventories/apache2.yml apache1 -m debug -a "var=hostvars[inventory_hostname]"

# Show facts
ansible -i inventories/apache2.yml apache1 -m setup

# Show a specific variable
ansible -i inventories/apache2.yml apache1 -m debug -a "var=ansible_hostname"
```

### Service verification

```bash
# Apache
docker exec apache-server-1 service apache2 status
docker exec apache-server-1 curl http://localhost

# Nginx
docker exec nginx-server-1 service nginx status
docker exec nginx-server-1 curl http://localhost:8080

# View logs
docker exec apache-server-1 cat /var/log/apache2/error.log
docker exec nginx-server-1 cat /var/log/nginx/error.log
```

### Tests from the host

```bash
# Access Nginx pages from your machine
curl http://localhost:8080  # Nginx 1
curl http://localhost:8081  # Nginx 2

# Or open in the browser
open http://localhost:8080  # macOS
xdg-open http://localhost:8080  # Linux
```

### Useful debugging commands

```bash
# Check playbook syntax
ansible-playbook --syntax-check -i inventories/apache2.yml playbooks/play-apache2.yml

# List tasks without executing them
ansible-playbook --list-tasks -i inventories/nginx.yml playbooks/play-nginx.yml

# Show targeted hosts
ansible-playbook --list-hosts -i inventories/apache2.yml playbooks/play-apache2.yml

# Run in step-by-step mode
ansible-playbook --step -i inventories/nginx.yml playbooks/play-nginx.yml
```

### Role management

```bash
# List available roles
ls -la roles/

# Role structure
tree roles/apache2/
tree roles/nginx/

# Test a role only
ansible -i inventories/apache2.yml apache1 -m include_role -a name=apache2
```

### Cleanup

```bash
# Remove all containers
docker-compose down

# Remove containers + volumes
docker-compose down -v

# Clean unused Docker images
docker system prune -a
```

## 🔧 Idempotence tests

```bash
# First run (should make changes)
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml

# Second run (should change nothing)
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml

# Check the result: "changed=0" = idempotent ✅
```

## 📊 Performance analysis

```bash
# Measure execution time
time ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml

# Profile tasks (slowest first)
ANSIBLE_CALLBACK_WHITELIST=profile_tasks ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml
```

## 🎯 Test scenarios

### Scenario 1: Initial deployment
```bash
docker-compose up -d
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml
```

### Scenario 2: Configuration change
```bash
# Modify group_vars/all.yml (e.g. change apache_port)
# Re-run the playbook
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml
# Verify the handler was triggered
```

### Scenario 3: Add a new server
```bash
# Add apache3 in inventories/apache2.yml
# Add the service in docker-compose.yml
docker-compose up -d
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml --limit apache3
```

### Scenario 4: Recovery after removal
```bash
# Remove Apache from a container
docker exec apache-server-1 apt-get remove -y apache2
# Re-run the playbook to restore
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml --limit apache1
```

## 💡 Tips

```bash
# Create aliases for long commands
alias ap-apache='ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml'
alias ap-nginx='ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml'

# Use
ap-apache
ap-nginx

# Environment variable for permanent verbose mode
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_VERBOSITY=1
```

---

📝 **Note**: All these commands must be run from the `correction/` folder
