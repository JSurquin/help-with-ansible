# Ansible examples — 2026 course

This directory contains **four progressive samples**, from a single playbook to a production-style layout.

## Overview

| Example | Level | What it shows | Concepts |
|---------|-------|---------------|----------|
| [01-simple-playbook](./01-simple-playbook/) | Beginner | Inventory + minimal playbook | Inventory, playbook, `apt` / `service` |
| [02-variables-templates](./02-variables-templates/) | Intermediate | Variables + Jinja2 templates | `group_vars`, templates, handlers |
| [03-avec-roles](./03-avec-roles/) | Advanced | Role-based layout | Roles, defaults, `meta`, reuse |
| [04-projet-production](./04-projet-production/) | Expert | Multi-env project skeleton | Staging/prod, Vault, `ansible.cfg` |

Folder names match the repository; open each `README.md` for exact commands.

## Prerequisites

```bash
# 1. From the repo root — start the lab
cd ../
docker-compose -f docker-compose-lab.yml up -d

# 2. Check containers
docker ps | grep ansible-lab

# 3. Install Ansible + Docker collection
pip install ansible
ansible-galaxy collection install community.docker
```

## How to run an example

```bash
cd exemples/01-simple-playbook/
cat README.md

ansible-playbook -i inventory.yml playbook.yml
```

## Example 1 — Simple playbook

**Goal:** first contact with Ansible.

```bash
cd 01-simple-playbook/
ansible-playbook -i inventory.yml playbook.yml
```

You practice:

- Defining an inventory  
- Writing a short playbook  
- Installing a package and starting a service  

## Example 2 — Variables and templates

**Goal:** customize configs with variables and Jinja2.

```bash
cd 02-variables-templates/
ansible-playbook -i inventory.yml playbook.yml
```

You practice:

- `group_vars/` layout  
- `.j2` templates  
- Dynamic files with `template`  
- Handlers  

**Important files:** `group_vars/all.yml`, `templates/*.j2`

## Example 3 — With roles

**Goal:** modular, reusable code.

```bash
cd 03-avec-roles/
ansible-playbook -i inventory.yml playbook.yml
```

Typical role layout:

```
roles/nginx/
├── tasks/
├── handlers/
├── templates/
├── defaults/
└── meta/
```

## Example 4 — Production-style project

**Goal:** professional structure with environments and Vault.

```bash
cd 04-projet-production/

ansible-playbook -i inventories/staging site.yml
ansible-playbook -i inventories/production site.yml
ansible-playbook -i inventories/production site.yml --ask-vault-pass
```

You practice:

- Project-wide `ansible.cfg`  
- Per-environment inventories  
- `group_vars` per environment  
- Encrypted secrets (`secrets.yml`)  
- Focused playbooks under `playbooks/`  
- Tags for partial runs  

## Ansible Vault (example 4)

```bash
cd 04-projet-production/

ansible-vault encrypt secrets.yml
ansible-vault edit secrets.yml
ansible-vault decrypt secrets.yml   # only if you really need plaintext on disk

ansible-playbook -i inventories/production site.yml --ask-vault-pass
```

## Customizing

1. Point inventories at your own hosts when you leave the lab.  
2. Tune values under `group_vars/` / `host_vars/`.  
3. Extend roles with extra tasks or templates.  

## Tips

1. Follow the numeric order (01 → 04).  
2. Read each example’s `README.md`.  
3. Edit variables and re-run to see idempotency in action.  

### Debugging helpers

```bash
ansible-playbook playbook.yml -vvv
ansible -i inventory.yml all -m ping
ansible-playbook playbook.yml --check
ansible-playbook playbook.yml --list-tasks
ansible-playbook playbook.yml --list-tags
```

## Further reading

- [Ansible docs](https://docs.ansible.com/)
- [Galaxy](https://galaxy.ansible.com/)
- [Playbook best practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

## Common issues

### Lab containers not reachable

```bash
docker ps | grep ansible-lab
docker-compose -f ../docker-compose-lab.yml restart
```

### Connection errors from Ansible

```bash
ansible -i inventory.yml all -m ping
docker exec ansible-lab-web01 python3 --version
```

### Missing collection / module

```bash
ansible-galaxy collection install community.general community.docker
```

## Next steps

1. Start your own small project.  
2. Publish roles to Galaxy when they are reusable.  
3. Call Ansible from CI (GitHub Actions, GitLab, Jenkins, …).  
4. Explore cloud collections as needed.  

Happy automating!
