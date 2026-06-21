# Example 3 — Using roles

## Description

Advanced sample: move installation logic into a reusable `nginx` role.

## Layout

```
03-avec-roles/
├── README.md
├── inventory.yml
├── playbook.yml
└── roles/
    └── nginx/
        ├── tasks/main.yml
        ├── handlers/main.yml
        ├── templates/
        │   ├── nginx.conf.j2
        │   └── vhost.conf.j2
        ├── defaults/main.yml
        └── meta/main.yml
```

## Goals

- Author a self-contained role  
- Keep playbooks thin (`roles: [nginx]`)  
- Reuse the same role from other playbooks  
- Provide defaults under `defaults/main.yml`  

## Run it

```bash
ansible-playbook -i inventory.yml playbook.yml

tree roles/
```

To reuse elsewhere:

```yaml
roles:
  - nginx
```

## Concepts

- Standard role directory layout  
- Modular tasks and handlers  
- `defaults/main.yml` vs other variable layers  
- `meta/main.yml` metadata (Galaxy, dependencies, platforms)  
- Sharing roles across projects  
