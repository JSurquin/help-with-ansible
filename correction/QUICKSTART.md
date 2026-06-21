# 🚀 Quick start — 2 minutes

## Prerequisites
- Docker installed and running
- Ansible installed (`pip install ansible`)

## In 4 commands

```bash
# 1. Go to the correction folder
cd correction

# 2. Start the infrastructure (4 containers)
docker-compose up -d

# 3. Wait 5 seconds for containers to be ready
sleep 5

# 4. Run the automated test script
./test.sh
```

## ✅ Expected result

You should see:
- ✓ Infrastructure started (4 containers)
- ✓ Ansible connectivity OK
- ✓ Apache2 playbook executed
- ✓ Nginx playbook executed
- ✓ Active services
- ✓ Web pages accessible

## 🌐 Test in the browser

With `correction/docker-compose.yml` (ports mapped on the host):
- http://localhost:9080 → Nginx server 1
- http://localhost:9081 → Nginx server 2

(Apache is not published on the host: test with `docker exec apache-server-1 curl http://localhost`.)

## 🧪 Same exercise with `docker-compose-lab.yml` (repository root)

Containers are named `ansible-lab-web01`, etc. (SSH + Python, also usable with `ansible_connection: docker` from the host).

```bash
# From the repository root (not correction/)
docker compose -f docker-compose-lab.yml up -d

# Then
cd correction
./test-lab.sh
```

Dedicated inventories: `inventories/lab/apache2.yml` (web01, web02) and `inventories/lab/nginx.yml` (web03, app01). The lab **does not expose** HTTP ports on the host: tests use `curl` **inside** the containers.

## 🎯 Manual execution

If you prefer to run playbooks manually:

```bash
# Start the infra
docker-compose up -d

# Deploy Apache2 (on apache1 and apache2)
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml

# Deploy Nginx (on nginx1 and nginx2)
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml

# Verify Apache works
docker exec apache-server-1 curl http://localhost

# Verify Nginx works
docker exec nginx-server-1 curl http://localhost:8080
```

## 🔍 Service verification

```bash
# Apache
docker exec apache-server-1 service apache2 status
docker exec apache-server-2 service apache2 status

# Nginx
docker exec nginx-server-1 service nginx status
docker exec nginx-server-2 service nginx status
```

## 🧹 Cleanup

```bash
# Stop and remove everything
docker-compose down
```

## 📚 Go further

- Read `README.md` for full documentation
- See `COMMANDS.md` for all available commands
- Modify templates in `roles/*/templates/`
- Add variables in `group_vars/all.yml`

## ⚠️ Common issues

### "Cannot connect to the Docker daemon"
```bash
# Start Docker
# macOS: Launch Docker Desktop
# Linux: sudo service docker start
```

### "Connection refused" during Ansible ping
```bash
# Wait for containers to be fully started
docker ps  # Verify all 4 containers are "Up"
sleep 10   # Wait a bit longer
```

### "Module not found" for Ansible
```bash
# Install Ansible
pip install ansible
# or
pip3 install ansible
```

---

🎉 **That's it! You have a complete Ansible infrastructure running!**
