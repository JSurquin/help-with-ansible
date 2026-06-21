# Example 4 — Production-style project

## Description

End-to-end layout inspired by real projects:

- Opinionated directory structure  
- Separate staging / production inventories  
- Multiple roles (`common`, `nginx`, `app`, …)  
- Ansible Vault for `secrets.yml`  
- Shared DevOps conventions (`ansible.cfg`, tags, focused playbooks)

## Layout (high level)

```
04-projet-production/
├── README.md
├── ansible.cfg
├── site.yml
├── inventories/
│   ├── production/hosts.yml
│   └── staging/hosts.yml
├── group_vars/
│   ├── all.yml
│   ├── production.yml
│   └── staging.yml
├── host_vars/
│   └── web01.yml
├── playbooks/
│   ├── deploy.yml
│   ├── backup.yml
│   └── monitoring.yml
├── roles/
│   ├── common/
│   ├── nginx/
│   ├── app/
│   └── monitoring/
└── secrets.yml            # encrypt with ansible-vault
```

## Goals

- Split environments cleanly  
- Layer variables (`all` + env + host)  
- Keep roles small and composable  
- Protect secrets with Vault  
- Run partial work with `--tags` and dedicated playbooks  
- Centralize Ansible settings in `ansible.cfg`  

## Run it

```bash
ansible-playbook -i inventories/staging site.yml

ansible-playbook -i inventories/production site.yml

ansible-playbook -i inventories/staging site.yml --tags "nginx,app"

ansible-playbook -i inventories/production playbooks/deploy.yml

ansible-playbook -i inventories/production site.yml --ask-vault-pass
```

## Concepts

- Production-style repo skeleton  
- Multi-environment inventories  
- Variable precedence in practice  
- Ansible Vault workflow  
- Selective execution (`--tags`, `--limit`)  
- Specialized playbooks under `playbooks/`  
- Role dependencies and shared `common` role patterns  
