# Basic Ansible Exercise 🚀

## Objective

Create your first Ansible inventory and playbook to manage the Docker lab servers.

**Estimated duration**: 45 minutes

---

## Prerequisites

### 1. Start the test infrastructure

```bash
# Start all lab containers
docker-compose -f docker-compose-lab.yml up -d

# Verify that containers are running (wait 30 seconds)
sleep 30
docker ps | grep ansible-lab
```

**What you should see**: 10 containers with the following names:
- `ansible-lab-web01`, `ansible-lab-web02`, `ansible-lab-web03` (web servers)
- `ansible-lab-db01`, `ansible-lab-db02` (databases)
- `ansible-lab-app01`, `ansible-lab-app02`, `ansible-lab-app03` (application servers)
- `ansible-lab-monitor01`, `ansible-lab-monitor02` (monitoring)

---

### 2. Verify that Ansible is installed

```bash
# Install Ansible if needed
pip3 install ansible

# Check the version
ansible --version
```

---

## Part 1: Create the inventory (15 min)

### Step 1.1: Create the working directory

```bash
# Create a directory for the exercise
mkdir -p exercice-basique-ansible
cd exercice-basique-ansible
```

---

### Step 1.2: Create the inventory.yml file

**Mission**: Create an `inventory.yml` file that organizes your 10 servers into groups.

**Expected structure**:
- A `webservers` group with web01, web02, web03
- A `databases` group with db01, db02
- An `appservers` group with app01, app02, app03
- A `monitoring` group with monitor01, monitor02

**Required configuration for ALL servers**:
- `ansible_connection: docker` (because we connect to containers)
- `ansible_user: root` (default user)
- `ansible_python_interpreter: /usr/bin/python3` (Python path)

**Hints**:
- Use YAML format
- Start with `all:` to define global variables
- Use `children:` to define groups
- For each host, set `ansible_host` to the Docker container name
  - Example: for web01, use `ansible_host: ansible-lab-web01`

**Additional help**:
```yaml
# Base structure to complete
---
all:
  vars:
    # Add the 3 global variables here
    ansible_connection: ???
    ansible_user: ???
    ansible_python_interpreter: ???

  children:
    webservers:
      hosts:
        web01:
          ansible_host: ???
        # Add web02 and web03
    
    databases:
      hosts:
        # Add db01 and db02
    
    # Add the appservers and monitoring groups
```

---

### Step 1.3: Test the inventory

```bash
# List all hosts in the inventory
ansible-inventory -i inventory.yml --list

# Verify connectivity with all servers (PING)
ansible all -i inventory.yml -m ping
```

**Expected result**: You should see "SUCCESS" in green for each server.

**If you get an error**:
- Verify that Docker containers are running
- Check the spelling of container names
- Check YAML indentation (2 spaces)

---

## Part 2: Create your first playbook (20 min)

### Step 2.1: Create the playbook.yml file

**Mission**: Create a playbook that configures all servers with basic tools.

**Tasks to implement in your playbook**:

1. **Display a welcome message**
   - Module: `debug`
   - Display: "Hello from [server name]"

2. **Update the APT cache**
   - Module: `apt`
   - Options: `update_cache: yes` and `cache_valid_time: 3600`

3. **Install basic tools**
   - Module: `apt`
   - Packages to install: `curl`, `vim`, `htop`, `net-tools`
   - State: `present`

4. **Create an information file**
   - Module: `copy`
   - Create the file `/tmp/ansible-info.txt`
   - Content: Server name and date
   - Mode: `0644`

5. **Display the content of the created file**
   - Module: `command`
   - Command: `cat /tmp/ansible-info.txt`
   - Store the result in a variable `file_content`
   - Add: `changed_when: false` (because this is read-only)

6. **Display system information**
   - Module: `debug`
   - Display: Distribution, version, architecture, memory

**Base structure**:
```yaml
---
- name: Basic server configuration
  hosts: ???  # Which servers?
  become: ???  # Do you need root privileges? (true/false)

  tasks:
    - name: Display a welcome message
      debug:
        msg: "👋 Hello from {{ ??? }}"
    
    - name: Update the APT cache
      apt:
        update_cache: ???
        cache_valid_time: ???
    
    # Continue with the other tasks...
```

**Useful Ansible variables**:
- `{{ inventory_hostname }}`: Server name in the inventory
- `{{ ansible_host }}`: Docker container name
- `{{ ansible_date_time.iso8601 }}`: ISO date/time
- `{{ ansible_distribution }}`: Distribution name (Ubuntu)
- `{{ ansible_distribution_version }}`: Version (22.04)
- `{{ ansible_architecture }}`: Architecture (x86_64)
- `{{ ansible_memtotal_mb }}`: Total memory in MB

---

### Step 2.2: Run the playbook

```bash
# Run the playbook on all servers
ansible-playbook -i inventory.yml playbook.yml
```

**Expected result**:
- All tasks should run successfully (status "ok" or "changed")
- You should see the welcome message for each server
- Packages should be installed
- The file `/tmp/ansible-info.txt` should be created

---

## Part 3: Playbook for a specific group (10 min)

### Step 3.1: Create playbook-webservers.yml

**Mission**: Create a playbook that configures ONLY the web servers.

**Tasks to implement**:

1. Create the directory `/var/www/html`
   - Module: `file`
   - Type: `directory`
   - Mode: `0755`

2. Create a simple HTML page
   - Module: `copy`
   - Destination: `/var/www/html/index.html`
   - Content: An HTML page that displays the server name
   - Mode: `0644`

**Hints**:
```yaml
---
- name: Web server configuration
  hosts: ???  # Which group to target?
  become: true

  tasks:
    - name: Create a web directory
      file:
        path: ???
        state: ???
        mode: ???
    
    - name: Create a simple web page
      copy:
        content: |
          <!DOCTYPE html>
          <html>
          <head><title>{{ ??? }}</title></head>
          <body>
            <h1>Web Server: {{ ??? }}</h1>
            <p>Configured with Ansible</p>
          </body>
          </html>
        dest: ???
        mode: ???
```

**Execution**:
```bash
ansible-playbook -i inventory.yml playbook-webservers.yml
```

---

## Part 4: Playbook with variables (10 min)

### Step 4.1: Create playbook-avec-variables.yml

**Mission**: Create a playbook with custom variables for database servers.

**Variables to define**:
- `db_port: 5432`
- `db_name: production`
- `admin_email: admin@example.com`

**Tasks to implement**:

1. Create a configuration file `/etc/db-config.conf`
   - Use the defined variables
   - Include the server name as well

2. Display the content of the created file

**Hints**:
```yaml
---
- name: Configuration with variables
  hosts: ???  # databases group
  become: true

  vars:
    db_port: ???
    db_name: ???
    admin_email: ???

  tasks:
    - name: Create a configuration file
      copy:
        content: |
          # Database configuration
          DB_PORT={{ ??? }}
          DB_NAME={{ ??? }}
          ADMIN_EMAIL={{ ??? }}
          HOSTNAME={{ ??? }}
        dest: ???
        mode: ???
    
    # Add a task to read and display the file
```

---

## Tests and verification

### Verify that everything works

```bash
# Verify that curl is installed everywhere
ansible all -i inventory.yml -m command -a "curl --version"

# Verify the ansible-info.txt file
ansible all -i inventory.yml -m command -a "cat /tmp/ansible-info.txt"

# Verify web pages (web servers only)
ansible webservers -i inventory.yml -m command -a "cat /var/www/html/index.html"

# Verify DB configuration (database servers only)
ansible databases -i inventory.yml -m command -a "cat /etc/db-config.conf"
```

---

## Useful ad-hoc commands to try

```bash
# Check the Ubuntu version on all servers
ansible all -i inventory.yml -m command -a "cat /etc/os-release"

# View disk space
ansible all -i inventory.yml -m command -a "df -h"

# Create a file on all servers
ansible all -i inventory.yml -m copy -a "content='Test Ansible' dest=/tmp/test.txt"

# Read the created file
ansible all -i inventory.yml -m command -a "cat /tmp/test.txt"

# Remove the file
ansible all -i inventory.yml -m file -a "path=/tmp/test.txt state=absent"
```

---

## Cleanup

```bash
# Remove test files
ansible all -i inventory.yml -m file -a "path=/tmp/ansible-info.txt state=absent"

# Stop the test infrastructure
cd ..
docker-compose -f docker-compose-lab.yml down

# Remove volumes (optional)
docker-compose -f docker-compose-lab.yml down -v
```

---

## Validation checklist ✅

Before moving on, make sure that:

- [ ] Your inventory contains all 4 groups with every server
- [ ] The command `ansible all -i inventory.yml -m ping` works for all servers
- [ ] Your main playbook runs without errors
- [ ] The tools (curl, vim, htop, net-tools) are installed on all servers
- [ ] The webservers playbook runs ONLY on web servers
- [ ] HTML pages are created on web servers
- [ ] DB configuration is created on database servers
- [ ] You know how to run ad-hoc commands

---

## Help and tips 💡

### Common issues

**Error "Could not match supplied host pattern"**
- Check the indentation of your inventory.yml
- Make sure all groups are under `children:`

**Docker connection error**
- Verify that containers are running: `docker ps | grep ansible-lab`
- Restart containers if needed

**APT error "Unable to acquire the dpkg frontend lock"**
- Wait 30 seconds after starting the containers
- Containers must finish their initialization

**Playbook does nothing**
- Verify that `hosts:` targets the correct group or `all`
- Verify that `become: true` is set if you need root privileges

---

## Going further 🚀

Once the exercise is complete, try to:

1. Create a playbook that installs nginx on the webservers
2. Use handlers to restart services
3. Create Jinja2 templates for configuration files
4. Organize your variables in separate files (group_vars/)
5. Create your first Ansible role

---

## Resources

- [Ansible Inventory documentation](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)
- [Ansible Playbooks documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html)
- [Ansible module index](https://docs.ansible.com/ansible/latest/collections/index_module.html)

**Solution available**: `exercice-basique-ansible.md` (consult after completing the exercise)

---

**Good luck! 🎉**
