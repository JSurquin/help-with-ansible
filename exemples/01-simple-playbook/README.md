# Example 1 — Simple playbook

## Description

Minimal Ansible sample: one inventory and one playbook to install and start Nginx.

## Layout

```
01-simple-playbook/
├── README.md
├── inventory.yml      # Managed hosts
└── playbook.yml       # Tasks to run
```

## Goals

- Define a small inventory  
- Author a short playbook  
- Install a package (`apt`)  
- Start/enable a service (`service`)  

## Run it

```bash
ansible -i inventory.yml all -m ping

ansible-playbook -i inventory.yml playbook.yml

curl http://localhost
```

*(Adjust URLs/ports if your lab maps HTTP differently.)*

## Concepts

- YAML inventory  
- Basic playbook structure  
- `apt` module  
- `service` module  
- Simple inline variables where shown in the playbook  
