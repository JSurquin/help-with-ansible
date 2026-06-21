# Basic Ansible Exercise 🚀

## Objective
Create your first Ansible inventory and playbook to manage the Docker lab servers.

This file is the **solution** to compare with the detailed instructions in `exercice-basique-ansible-consignes.md`: the playbooks below implement **exactly** what is requested there (inventory, `playbook.yml`, `playbook-webservers.yml`, `playbook-avec-variables.yml`). The ad-hoc commands and summary sections also include additional examples to go further.

---

## Prerequisites

### 1. Start the test infrastructure

```bash
# Start all lab containers
docker-compose -f docker-compose-lab.yml up -d

# Verify that containers are running (wait 30 seconds)
sleep 30
docker ps | grep ansible-lab

# You should see 10 containers:
# - 3 web servers (web01, web02, web03)
# - 2 database servers (db01, db02)
# - 3 application servers (app01, app02, app03)
# - 2 monitoring servers (monitor01, monitor02)
```

### 2. Verify that Ansible is installed

```bash
# Install Ansible if needed
pip3 install ansible

# Check the version
ansible --version
```

---

## Part 1: Create the inventory

### Create the working directory

```bash
# Create a directory for the exercise
mkdir -p exercice-basique-ansible
cd exercice-basique-ansible
```

---

### Create the inventory.yml file

```yaml
# inventory.yml
---
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

    databases:
      hosts:
        db01:
          ansible_host: ansible-lab-db01
        db02:
          ansible_host: ansible-lab-db02

    appservers:
      hosts:
        app01:
          ansible_host: ansible-lab-app01
        app02:
          ansible_host: ansible-lab-app02
        app03:
          ansible_host: ansible-lab-app03

    monitoring:
      hosts:
        monitor01:
          ansible_host: ansible-lab-monitor01
        monitor02:
          ansible_host: ansible-lab-monitor02
```

---

### Test the inventory

```bash
# List all hosts in the inventory
ansible-inventory -i inventory.yml --list

# Verify connectivity with all servers
ansible all -i inventory.yml -m ping

# You should see SUCCESS for each server
```

---

## Part 2: Create your first playbook

### Create the playbook.yml file

Aligned with the instructions (welcome message, APT, packages, minimal information file, file read, then system info debug).

```yaml
# playbook.yml
---
- name: Basic server configuration
  hosts: all
  become: true

  tasks:
    - name: Display a welcome message
      debug:
        msg: "👋 Hello from {{ inventory_hostname }}"

    - name: Update the APT cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install basic tools
      apt:
        name:
          - curl
          - vim
          - htop
          - net-tools
        state: present

    - name: Create an information file
      copy:
        content: |
          Server name: {{ inventory_hostname }}
          Date: {{ ansible_date_time.iso8601 }}
        dest: /tmp/ansible-info.txt
        mode: '0644'

    - name: Display the content of the created file
      command: cat /tmp/ansible-info.txt
      register: file_content
      changed_when: false

    - name: Display system information
      debug:
        msg: |
          Distribution: {{ ansible_distribution }}
          Version: {{ ansible_distribution_version }}
          Architecture: {{ ansible_architecture }}
          Memory (MB): {{ ansible_memtotal_mb }}
```

---

### Run the playbook

```bash
# Run the playbook on all servers
ansible-playbook -i inventory.yml playbook.yml

# You should see all tasks run successfully
```

---

## Part 3: Playbook for a specific group

### playbook-webservers.yml

```yaml
# playbook-webservers.yml
---
- name: Web server configuration
  hosts: webservers
  become: true

  tasks:
    - name: Create a web directory
      file:
        path: /var/www/html
        state: directory
        mode: '0755'

    - name: Create a simple web page
      copy:
        content: |
          <!DOCTYPE html>
          <html>
          <head><title>{{ inventory_hostname }}</title></head>
          <body>
            <h1>Web Server: {{ inventory_hostname }}</h1>
            <p>Configured with Ansible</p>
          </body>
          </html>
        dest: /var/www/html/index.html
        mode: '0644'
```

```bash
# Run only on webservers
ansible-playbook -i inventory.yml playbook-webservers.yml
```

---

## Part 4: Playbook with variables

### playbook-avec-variables.yml

```yaml
# playbook-avec-variables.yml
---
- name: Configuration with variables
  hosts: databases
  become: true

  vars:
    db_port: 5432
    db_name: production
    admin_email: admin@example.com

  tasks:
    - name: Create a configuration file
      copy:
        content: |
          # Database configuration
          DB_PORT={{ db_port }}
          DB_NAME={{ db_name }}
          ADMIN_EMAIL={{ admin_email }}
          HOSTNAME={{ inventory_hostname }}
        dest: /etc/db-config.conf
        mode: '0644'

    - name: Display the content of the created file
      command: cat /etc/db-config.conf
      register: db_config_content
      changed_when: false

    - name: Show the configuration
      debug:
        var: db_config_content.stdout_lines
```

```bash
# Run on database servers
ansible-playbook -i inventory.yml playbook-avec-variables.yml
```

---

## Part 5: Useful ad-hoc commands (extras)

```bash
# Check the Ubuntu version on all servers
ansible all -i inventory.yml -m command -a "cat /etc/os-release"

# View the distribution in a formatted way
ansible all -i inventory.yml -m setup -a "filter=ansible_distribution*"

# Create a directory on web servers
ansible webservers -i inventory.yml -m file -a "path=/tmp/test state=directory mode=0755"

# Copy a file to all servers
ansible all -i inventory.yml -m copy -a "content='Hello World from Ansible' dest=/tmp/hello.txt mode=0644"

# Read the created file
ansible all -i inventory.yml -m command -a "cat /tmp/hello.txt"

# View disk space on all servers
ansible all -i inventory.yml -m command -a "df -h"

# View processes on webservers
ansible webservers -i inventory.yml -m command -a "ps aux | head -10"

# View available memory
ansible all -i inventory.yml -m command -a "free -h"

# Check server uptime
ansible all -i inventory.yml -m command -a "uptime"

# List logged-in users
ansible all -i inventory.yml -m command -a "who"

# Create a test user (advanced example)
ansible appservers -i inventory.yml -m user -a "name=testuser state=present shell=/bin/bash"

# Install a package on a specific group
ansible monitoring -i inventory.yml -m apt -a "name=htop state=present update_cache=yes" --become

# View variables for a specific server
ansible web01 -i inventory.yml -m setup

# Filter network variables
ansible all -i inventory.yml -m setup -a "filter=ansible_default_ipv4"

# Filter memory variables
ansible all -i inventory.yml -m setup -a "filter=ansible_mem*"

# Copy a local file to servers
echo "Test file" > /tmp/local-file.txt
ansible webservers -i inventory.yml -m copy -a "src=/tmp/local-file.txt dest=/tmp/remote-file.txt"

# Create a file with specific permissions
ansible databases -i inventory.yml -m file -a "path=/tmp/secure-file.txt state=touch mode=0600 owner=root"

# Check if a package is installed
ansible all -i inventory.yml -m command -a "dpkg -l | grep curl"

# Restart a service (example with an existing service)
ansible all -i inventory.yml -m service -a "name=ssh state=restarted" --become

# Get only specific information
ansible all -i inventory.yml -m setup -a "filter=ansible_hostname"
ansible all -i inventory.yml -m setup -a "filter=ansible_processor_vcpus"
ansible all -i inventory.yml -m setup -a "filter=ansible_memtotal_mb"
```

---

## Part 6: Verification and tests

### Test the configuration

```bash
# Verify that tools are installed on all servers
ansible all -i inventory.yml -m command -a "curl --version"
ansible all -i inventory.yml -m command -a "vim --version"

# Verify the ansible-info.txt file on each server
ansible all -i inventory.yml -m command -a "cat /tmp/ansible-info.txt"

# Verify web servers
ansible webservers -i inventory.yml -m command -a "cat /var/www/html/index.html"

# Verify database servers
ansible databases -i inventory.yml -m command -a "cat /etc/db-config.conf"
```

---

## Part 7: Cleanup

```bash
# Remove test files
ansible all -i inventory.yml -m file -a "path=/tmp/ansible-info.txt state=absent"
ansible all -i inventory.yml -m file -a "path=/tmp/hello.txt state=absent"

# Stop the test infrastructure
cd ..
docker-compose -f docker-compose-lab.yml down

# Remove volumes (optional)
docker-compose -f docker-compose-lab.yml down -v
```

---

## Summary

### What you learned ✅

1. **Ansible inventory**
   - YAML structure with groups and hosts
   - Global variables (`all.vars`)
   - Server groups (webservers, databases, appservers, monitoring)
   - Docker connection variables
   - Hierarchical server organization

2. **Basic playbooks**
   - Playbook structure (`name`, `hosts`, `become`, `tasks`)
   - Simple tasks (debug, apt, copy, command, file)
   - Built-in Ansible variables:
     - `{{ inventory_hostname }}` - Server name
     - `{{ ansible_host }}` - Docker container
     - `{{ ansible_distribution }}` - Linux distribution
     - `{{ ansible_distribution_version }}` - Version
     - `{{ ansible_architecture }}` - System architecture
     - `{{ ansible_memtotal_mb }}` - Total memory
     - `{{ ansible_processor_vcpus }}` - Number of CPUs
     - `{{ ansible_date_time.iso8601 }}` - ISO date/time
     - `{{ ansible_user }}` - Connection user
     - `{{ ansible_python_interpreter }}` - Python path
     - `{{ group_names }}` - List of groups
   - Custom variables in `vars:`
   - Storing results with `register:`
   - Jinja2 filters: additional examples (`join`, conditions, etc.) appear in the "Useful ad-hoc commands (extras)" section

3. **Essential Ansible modules**
   - `ping`: Test connectivity
   - `debug`: Display information (msg, var)
   - `apt`: Manage packages (install, update_cache)
   - `copy`: Copy/create files (content, dest, mode)
   - `file`: Manage files/directories (path, state, mode, owner)
   - `command`: Run commands (+ changed_when)
   - `setup`: Collect facts (filter)
   - `user`: Manage users
   - `service`: Manage services

4. **Ad-hoc commands**
   - Quick execution without a playbook
   - Syntax: `ansible <hosts> -i <inventory> -m <module> -a "<args>"`
   - Useful options: `--become`, `--check`, `--diff`
   - Filtering with `setup` and `filter=`
   - Useful for tests, debugging, and one-off operations

5. **Best practices**
   - Logical group organization
   - Using variables for reusability
   - Mode `0644` for files, `0755` for directories
   - `changed_when: false` for read-only commands
   - `become: true` when root privileges are required
   - Comments in playbooks
   - Clear task names and messages

---

## Next steps 🚀

Now that you have mastered the basics, you can:

1. Create more complex playbooks
2. Use Jinja2 templates
3. Create Ansible roles
4. Manage advanced variables
5. Use handlers

**Congratulations! You have completed the basic Ansible exercise!** 🎉
