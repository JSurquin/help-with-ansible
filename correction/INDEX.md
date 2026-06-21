# 📚 Solution index — group Ansible exercise

## 🎯 Overview

This complete reference solution illustrates a professional Ansible infrastructure with 4 servers (2 Apache2 + 2 Nginx), managed through dedicated playbooks, roles, inventories, and templates.

---

## 📖 Available documentation

### 🚀 Getting started guides

| File | Description | Reading time |
|---------|-------------|------------------|
| **QUICKSTART.md** | Ultra-fast start (4 commands) | 2 min |
| **README.md** | Full project documentation | 10 min |
| **COMMANDS.md** | Reference for all commands | 15 min |
| **EXPLICATIONS.md** | Detailed concepts and architecture | 30 min |
| **INDEX.md** | This file (overview) | 5 min |

---

## 🗂️ File structure

### Configuration files
```
correction/
├── ansible.cfg                 # Ansible configuration (roles path)
├── group_vars/all.yml          # Global variables (ansible_connection: docker)
├── .gitignore                  # Files to ignore
└── docker-compose.yml          # Docker infrastructure (4 containers)
```

### Inventories
```
inventories/
├── apache2.yml                 # 2 Apache servers (apache1, apache2)
└── nginx.yml                   # 2 Nginx servers (nginx1, nginx2)
```

### Playbooks
```
playbooks/
├── play-apache2.yml            # Apache2 deployment
└── play-nginx.yml              # Nginx deployment
```

### Apache2 role
```
roles/apache2/
├── tasks/main.yml              # Installation and configuration
├── handlers/main.yml           # Restart/reload
├── vars/main.yml               # Role variables
└── templates/
    ├── apache2.conf.j2         # Apache configuration
    └── index.html.j2           # Custom home page
```

### Nginx role
```
roles/nginx/
├── tasks/main.yml              # Installation and configuration
├── handlers/main.yml           # Restart/reload
├── vars/main.yml               # Role variables
└── templates/
    ├── nginx.conf.j2           # Nginx configuration
    └── index.html.j2           # Custom home page
```

### Scripts and tools
```
test.sh                         # Automated test script
```

---

## 🎓 Where to start?

### Beginner level
1. **Read**: `QUICKSTART.md` to get up and running quickly
2. **Run**: `./test.sh` to see the solution in action
3. **Explore**: Open http://localhost:8080 and http://localhost:8081
4. **Read**: `README.md` to understand the structure

### Intermediate level
1. **Read**: `EXPLICATIONS.md` to understand the concepts
2. **Practice**: Modify templates and re-run
3. **Experiment**: Add a 3rd server
4. **Consult**: `COMMANDS.md` for advanced commands

### Advanced level
1. **Analyze**: Architecture and design choices
2. **Optimize**: Performance and security
3. **Extend**: Add new roles (MySQL, Redis, etc.)
4. **Integrate**: CI/CD, monitoring, logging

---

## 🚀 Quick start (reminder)

```bash
cd correction
docker-compose up -d
sleep 5
./test.sh
```

**Result**: Full operational infrastructure in 1 minute!

---

## 🔍 Important files

### Global configuration
- **ansible.cfg**: Project Ansible configuration
  - Roles path: `./roles`
  - Display and connection options
- **group_vars/all.yml**: Variables shared by all servers
  - `ansible_connection: docker`
  - Default ports (apache: 80, nginx: 8080)
  - Admin email

### Inventories
- **inventories/apache2.yml**: Defines apache1 and apache2
- **inventories/nginx.yml**: Defines nginx1 and nginx2

### Playbooks
- **playbooks/play-apache2.yml**: Applies the apache2 role to apache_servers
- **playbooks/play-nginx.yml**: Applies the nginx role to nginx_servers

### Roles
- **roles/apache2/**: Everything needed to install and configure Apache
- **roles/nginx/**: Everything needed to install and configure Nginx

---

## 📊 Ansible concepts covered

### ✅ Level 1: Fundamentals
- [x] Inventories (hosts and groups)
- [x] Playbooks (orchestration)
- [x] Tasks (actions)
- [x] Modules (apt, service, file, template)

### ✅ Level 2: Intermediate
- [x] Roles (reusable organization)
- [x] Variables (group_vars, vars)
- [x] Templates (Jinja2)
- [x] Handlers (restart management)

### ✅ Level 3: Advanced
- [x] Idempotence (reruns without side effects)
- [x] Separation of concerns (Clean Architecture)
- [x] Infrastructure as Code
- [x] Docker as an Ansible target

---

## 🧪 Available tests

### Full automated test
```bash
./test.sh
```
Checks:
- ✓ Containers running
- ✓ Ansible connectivity
- ✓ Playbook execution
- ✓ Active services
- ✓ Web pages accessible
- ✓ Idempotence

### Manual tests
```bash
# Test connectivity
ansible -i inventories/apache2.yml all -m ping

# Check a service
docker exec apache-server-1 service apache2 status

# Test a web page
curl http://localhost:8080
```

---

## 🌐 Application access

### From the browser
- **Nginx Server 1**: http://localhost:8080
- **Nginx Server 2**: http://localhost:8081

### From containers
```bash
# Apache
docker exec apache-server-1 curl http://localhost
docker exec apache-server-2 curl http://localhost

# Nginx
docker exec nginx-server-1 curl http://localhost:8080
docker exec nginx-server-2 curl http://localhost:8080
```

---

## 💡 FAQ

### Q: Why 2 separate inventories?
**A:** Allows independent deployment of Apache and Nginx. In production, you might have separate environments (dev, staging, prod).

### Q: Why roles and not just tasks?
**A:** Roles enable reuse, organization, and portability of code.

### Q: Why Docker and not SSH?
**A:** For training, Docker is faster and lighter. In production, just change `ansible_connection: ssh`.

### Q: How to adapt for production?
**A:** 
1. Replace `ansible_connection: docker` with `ansible_connection: ssh`
2. Put real IPs in the inventories
3. Configure SSH keys
4. Add Ansible Vault for secrets

### Q: Can I add other servers?
**A:** Yes! Add them in:
1. `docker-compose.yml` (container)
2. `inventories/*.yml` (inventory)
3. Re-run the playbook

---

## 🎯 Suggested exercises

### Exercise 1: Modify a variable
1. Change `apache_port` in `group_vars/all.yml`
2. Re-run the Apache playbook
3. Verify that the handler was triggered

### Exercise 2: Customize templates
1. Modify `roles/apache2/templates/index.html.j2`
2. Add your own message or CSS styling
3. Deploy and verify

### Exercise 3: Add a server
1. Add `apache3` in `inventories/apache2.yml`
2. Add the service in `docker-compose.yml`
3. Run `docker-compose up -d`
4. Deploy with `--limit apache3`

### Exercise 4: Create a new role
1. Create `roles/mysql/` with the same structure
2. Implement MySQL installation
3. Create a playbook and inventory
4. Test

### Exercise 5: Check mode and diff
1. Modify a variable
2. Run with `--check --diff`
3. Observe planned changes without applying them

---

## 🔧 Essential commands (reminder)

```bash
# Infrastructure
docker-compose up -d                    # Start
docker-compose down                     # Stop

# Ansible
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml

# Tests
./test.sh                               # Full test
ansible -i inventories/apache2.yml all -m ping    # Connectivity test

# Debug
docker exec -it apache-server-1 bash    # Enter the container
docker logs apache-server-1             # View logs
```

---

## 📚 External resources

### Official documentation
- [Ansible Docs](https://docs.ansible.com)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Galaxy](https://galaxy.ansible.com)

### Modules used
- [apt module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)
- [service module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html)
- [template module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)
- [file module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)

---

## ✅ Understanding checklist

After going through this solution, you should be able to:

- [ ] Explain the difference between a playbook and a role
- [ ] Create an inventory with multiple groups
- [ ] Write a playbook that uses a role
- [ ] Create a complete role (tasks, handlers, vars, templates)
- [ ] Use variables and facts in templates
- [ ] Understand how handlers work
- [ ] Test playbook idempotence
- [ ] Debug a deployment issue
- [ ] Adapt this structure for a new project

---

## 🎉 Conclusion

This solution represents a **professional Ansible architecture** you can use as a foundation for your own projects.

**Strengths**:
✅ Clear and scalable organization
✅ Maximum reusability
✅ Best practices applied
✅ Complete documentation
✅ Automated tests
✅ Production-ready (with adaptations)

**Next steps**:
1. Understand each file
2. Modify and experiment
3. Create your own roles
4. Deploy to real servers

---

📧 **Questions or suggestions?** Feel free to ask during the training!

🚀 **Happy deploying with Ansible 2026!**
