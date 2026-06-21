---
routeAlias: 'qcm-ansible'
---

<a name="QCM_ANSIBLE" id="QCM_ANSIBLE"></a>

# Quiz: Ansible Assessment

### Test your knowledge by module

---

# Module 1: Ansible Fundamentals

### Question 1

What is the fundamental principle of Ansible?

A) Ansible requires agents on all target servers

B) Ansible works in "push" mode without agents

C) Ansible only uses the HTTP protocol

D) Ansible completely replaces SSH

---

### Question 2

What are the main components of Ansible?

A) Control Node, Managed Nodes, Playbooks

B) Master, Workers, Registry

C) Client, Server, Database

D) Controller, Executors, Storage

---

### Question 3

What does "idempotent" mean in the Ansible context?

A) Tasks always execute faster the second time

B) Running a playbook multiple times produces the same result

C) Errors are automatically corrected

D) Tasks are executed in parallel

---

# Module 2: Inventories and Playbooks

### Question 4

What is an Ansible inventory?

A) The list of available playbooks

B) The list of servers and groups managed by Ansible

C) The execution history

D) The catalog of available modules

---

### Question 5

In what format are Ansible playbooks written?

A) JSON

B) XML

C) YAML

D) TOML

---

### Question 6

How to execute a playbook with a specific inventory?

A) `ansible-playbook playbook.yml -i inventory.yml`

B) `ansible playbook.yml --inventory inventory.yml`

C) `ansible-run -p playbook.yml -i inventory.yml`

D) `ansible execute playbook.yml inventory.yml`

---

# Module 3: Modules and Variables

### Question 7

What is the difference between a module and a role?

A) A module is reusable, a role is not

B) A module executes a specific task, a role is an organized set of tasks

C) A role is faster than a module

D) There is no difference

---

### Question 8

Which command executes an ad-hoc task on all web servers?

A) `ansible webservers -m ping`

B) `ansible-playbook -i webservers ping.yml`

C) `ansible all -m webservers -a ping`

D) `ansible run webservers ping`

---

### Question 9

How to define a variable in a playbook?

A) `set var_name: value`

B) `vars: var_name = value`

C) `vars:` followed by `var_name: value`

D) `define: var_name value`

---

# Module 4: Templates and Handlers

### Question 10

Which template language does Ansible use?

A) Mustache

B) Jinja2

C) Handlebars

D) EJS

---

### Question 11

When is a handler executed?

A) Immediately when called

B) At the end of the playbook, only if notified and the task changed something

C) At the beginning of each play

D) Only in case of error

---

### Question 12

How to call a handler from a task?

A) `trigger: handler_name`

B) `call: handler_name`

C) `notify: handler_name`

D) `execute: handler_name`

---

# Module 5: Roles and Collections

### Question 13

What is the standard structure of an Ansible role?

A) `tasks/, handlers/, vars/, files/`

B) `src/, build/, test/, deploy/`

C) `main/, config/, scripts/, docs/`

D) `playbooks/, inventories/, modules/, plugins/`

---

### Question 14

How to install an Ansible collection from Galaxy?

A) `ansible install collection community.docker`

B) `ansible-galaxy collection install community.docker`

C) `ansible-galaxy install community.docker`

D) `ansible add-collection community.docker`

---

### Question 15

Where are roles downloaded from Ansible Galaxy stored by default?

A) `~/.ansible/roles/`

B) `/etc/ansible/roles/`

C) `./roles/`

D) `/usr/share/ansible/roles/`

---

# Module 6: Ansible Vault and Security

### Question 16

What is Ansible Vault used for?

A) Securely storing playbooks

B) Encrypting sensitive data like passwords

C) Backing up the inventory

D) Managing playbook versions

---

### Question 17

How to create an encrypted file with Ansible Vault?

A) `ansible-vault encrypt secrets.yml`

B) `ansible-vault create secrets.yml`

C) `ansible vault new secrets.yml`

D) `ansible-encrypt secrets.yml`

---

### Question 18

Which is NOT a good security practice with Ansible?

A) Use Ansible Vault for secrets

B) Store SSH keys in playbooks

C) Limit privileges with `become_user`

D) Use SSH connections with keys

---

# Module 7: Error Handling and Tags

### Question 19

How to ignore errors for a specific task?

A) `ignore_errors: true`

B) `failed_when: false`

C) `error_handling: ignore`

D) `skip_errors: yes`

---

### Question 20

What are tags used for in Ansible?

A) Identifying playbook versions

B) Executing only certain tasks of a playbook

C) Categorizing servers in the inventory

D) Marking errors in logs

---

### Question 21

How to execute only tasks with the "config" tag?

A) `ansible-playbook playbook.yml --tag config`

B) `ansible-playbook playbook.yml --tags config`

C) `ansible-playbook playbook.yml -t config`

D) Answers B and C are correct

---

# Module 8: Best Practices and CI/CD

### Question 22

How to implement blue-green deployment with Ansible?

A) Use distinct inventory groups and conditional variables

B) Create two separate playbooks

C) Use only roles

D) Impossible with Ansible alone

---

### Question 23

What is the best way to organize a production Ansible project?

A) Put everything in a single playbook.yml file

B) Use a structure with roles/, inventories/, group_vars/

C) Create one file per server

D) Use only ad-hoc commands

---

### Question 24

In which context is `delegate_to` used?

A) To delegate a task to a different server than the current host

B) To grant sudo permissions

C) To transfer files

D) To execute tasks in parallel

---

### Question 25

Which directive allows continuing execution even if a task fails on some hosts?

A) `continue_on_failure: true`

B) `any_errors_fatal: false`

C) `ignore_all_errors: true`

D) `force_continue: true`

---

#### 📊 Answers - All modules

<small>

#### Complete corrections

**Module 1: Fundamentals**
- Question 1: **B** - Ansible works in "push" mode without agents
- Question 2: **A** - Control Node, Managed Nodes, Playbooks
- Question 3: **B** - Running a playbook multiple times produces the same result

**Module 2: Inventories and Playbooks**
- Question 4: **B** - The list of servers and groups managed by Ansible
- Question 5: **C** - YAML
- Question 6: **A** - `ansible-playbook playbook.yml -i inventory.yml`

**Module 3: Modules and Variables**
- Question 7: **B** - A module executes a specific task, a role is an organized set of tasks
- Question 8: **A** - `ansible webservers -m ping`
- Question 9: **C** - `vars:` followed by `var_name: value`

</small>

---

#### 📊 Answers (continued)

<small>

**Module 4: Templates and Handlers**
- Question 10: **B** - Jinja2
- Question 11: **B** - At the end of the playbook, only if notified and the task changed something
- Question 12: **C** - `notify: handler_name`

**Module 5: Roles and Collections**
- Question 13: **A** - `tasks/, handlers/, vars/, files/`
- Question 14: **B** - `ansible-galaxy collection install community.docker`
- Question 15: **A** - `~/.ansible/roles/`

**Module 6: Ansible Vault and Security**
- Question 16: **B** - Encrypting sensitive data like passwords
- Question 17: **B** - `ansible-vault create secrets.yml`
- Question 18: **B** - Storing SSH keys in playbooks

</small>

---

#### 📊 Answers (end)

<small>

**Module 7: Error Handling and Tags**
- Question 19: **A** - `ignore_errors: true`
- Question 20: **B** - Executing only certain tasks of a playbook
- Question 21: **D** - Answers B and C are correct

**Module 8: Best Practices and CI/CD**
- Question 22: **A** - Use distinct inventory groups and conditional variables
- Question 23: **B** - Use a structure with roles/, inventories/, group_vars/
- Question 24: **A** - To delegate a task to a different server than the current host
- Question 25: **B** - `any_errors_fatal: false`

</small>

---

#### 🎯 Grading scale

<small>

#### Assess your level

- **23-25 correct answers**: 🏆 Ansible Expert! You have perfect mastery
- **20-22 correct answers**: 🥇 Advanced level - Excellent work
- **16-19 correct answers**: 🥈 Good level - Some revision recommended
- **12-15 correct answers**: 🥉 Intermediate level - Keep practicing
- **< 12 correct answers**: 📚 Review the fundamentals

</small>

---

#### 💡 Key points to remember

<small>

#### Essential concepts

✅ **Idempotence**: Ansible guarantees the same result on each execution

✅ **Agentless**: Uses SSH, no need to install agents on target servers

✅ **YAML**: Standard format for playbooks, readable and simple

✅ **Jinja2**: Template engine for generating dynamic configurations

✅ **Vault**: Encrypting sensitive data (passwords, API keys)

✅ **Roles**: Modular and reusable code organization

✅ **Tags**: Selective execution of parts of a playbook

✅ **Handlers**: Actions triggered only if a task changes something

</small>

---

#### 🚀 Next steps

#### Going further

<small>

**Deepening**
- 📖 Official Ansible documentation
- 🎥 Ansible YouTube channel
- 🌟 Ansible Galaxy for community roles

**Advanced tools**
- **Ansible Tower/AWX**: Web interface and orchestration
- **Molecule**: Automated role testing
- **Ansible Lint**: Code quality checking

**Integrations**
- **CI/CD**: GitLab, Jenkins, GitHub Actions
- **Kubernetes**: Ansible Operator
- **Cloud**: AWS, Azure, GCP modules

**💡 Tip**: Practice by creating your own roles and contribute to the community!

</small>