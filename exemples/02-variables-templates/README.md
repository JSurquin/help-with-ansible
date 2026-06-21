# Example 2 — Variables and templates

## Description

Intermediate sample: shared variables plus Jinja2 templates to render Nginx config and HTML.

## Layout

```
02-variables-templates/
├── README.md
├── inventory.yml
├── playbook.yml
├── group_vars/
│   └── all.yml
└── templates/
    ├── nginx.conf.j2
    └── index.html.j2
```

## Goals

- Centralize values in `group_vars/`  
- Use `.j2` templates  
- Render dynamic configuration files  
- Call the `template` module  
- Optionally use facts such as `inventory_hostname`  

## Run it

```bash
ansible-playbook -i inventory.yml playbook.yml

curl http://localhost
```

## Concepts

- `group_vars/` organization  
- Jinja2 syntax in templates  
- `template` task  
- Dynamic configuration from variables  
- Inventory-derived variables (`inventory_hostname`, IP facts, …)  
