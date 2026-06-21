# Ansible lab quick start

This guide starts the **Docker-based training lab**: ten Ubuntu containers that behave like a small fleet of Linux hosts.

## Goal

Practice Ansible against multiple targets **without** provisioning full VMs.

## Prerequisites

- Docker and Docker Compose installed on the workstation  
- Ansible installed (`pip install ansible` or your preferred method)  
- `ansible-galaxy collection install community.docker`  

## First-time startup (important)

The first boot can take **5–10 minutes** while each container installs SSH, Python 3, and sudo. Duration depends on CPU, disk, and network.

### Option A — helper script (recommended)

```bash
chmod +x wait-for-lab.sh
./wait-for-lab.sh
```

The script typically:

- Brings up all 10 containers  
- Waits until they respond to Ansible  
- Prints total wait time  

### Option B — manual flow

```bash
docker-compose -f docker-compose-lab.yml up -d

# Watch first-boot package installs (optional)
docker logs -f ansible-lab-web01

docker ps
```

You should eventually see **10** `ansible-lab-*` containers:

- 3 web (`web01`–`web03`)  
- 2 databases (`db01`–`db02`)  
- 3 app (`app01`–`app03`)  
- 2 monitoring (`monitor01`–`monitor02`)  

## Wait until Ansible can ping everything

Containers must finish bootstrapping before `ping` succeeds.

```bash
ansible -i inventory-lab.yml all -m ping
```

- If you see **`python3: not found`** (or similar), packages are still installing — wait 2–3 minutes and retry.  
- When every host returns **`SUCCESS => pong`**, the lab is ready.  

**Rough timing**

- First ever pull: **5–10 minutes**  
- Later runs (cached layers): **2–3 minutes**  
- Pre-built images (if you maintain them): **< 30 seconds**  

## Sanity checks

```bash
ansible-inventory -i inventory-lab.yml --graph

ansible -i inventory-lab.yml webservers -m command -a "hostname"

docker exec ansible-lab-web01 python3 --version
```

## Minimal test playbook

```bash
cat > test.yml << 'EOF'
---
- name: Connectivity smoke test
  hosts: all
  tasks:
    - name: Gather hostname
      command: hostname
      register: result

    - name: Show hostname
      debug:
        msg: "Host {{ inventory_hostname }} -> {{ result.stdout }}"
EOF

ansible-playbook -i inventory-lab.yml test.yml
```

## Lab topology (ASCII)

```
┌─────────────────────────────────────────┐
│         Ansible control node            │
│         (your machine)                  │
└────────────────┬────────────────────────┘
                 │
         ┌───────┴───────┐
         │ Docker network │
         └───────┬────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
┌───▼───┐   ┌───▼───┐   ┌───▼────┐
│ Web   │   │  DB   │   │  App   │
│ (x3)  │   │ (x2)  │   │ (x3)   │
└───────┘   └───────┘   └────────┘
```

*(Plus monitoring hosts — see `inventory-lab.yml` for authoritative group names.)*

## Inventory groups (from `inventory-lab.yml`)

- `webservers` — `web01`, `web02`, `web03`  
- `databases` — `db01`, `db02`  
- `appservers` — `app01`, `app02`, `app03`  
- `monitoring` — `monitor01`, `monitor02`  
- `production` — combines web + DB + app tiers  
- `infrastructure` — monitoring tier  

## Useful ad-hoc examples

```bash
ansible -i inventory-lab.yml all -m apt -a "update_cache=yes" -b

ansible -i inventory-lab.yml webservers -m apt -a "name=nginx state=present" -b

ansible -i inventory-lab.yml all -m command -a "df -h"

ansible -i inventory-lab.yml databases -m reboot -b
```

## Stop the lab

```bash
docker-compose -f docker-compose-lab.yml down

docker-compose -f docker-compose-lab.yml down -v   # full reset (removes volumes)
```

## Troubleshooting

### Containers fail to start

```bash
docker-compose -f docker-compose-lab.yml logs
docker restart ansible-lab-web01
```

### Ansible still cannot connect

```bash
docker ps | grep ansible-lab
docker exec -it ansible-lab-web01 bash
docker exec ansible-lab-web01 python3 --version
```

### Full reset

```bash
docker-compose -f docker-compose-lab.yml down -v
docker-compose -f docker-compose-lab.yml up -d
```

## Tips

- The lab is **meant to be disposable** — tear it down and recreate often.  
- Practice `--limit` on a subset before hitting `all`.  
- Use inventory groups instead of long host lists.  
- `docker logs ansible-lab-web01` is your friend when cloud-init style steps hang.  

## Ready

When `ansible ... -m ping` is green:

1. Follow the exercises under `pages/14-exercices-ansible.md`.  
2. Try the samples in `exemples/`.  
3. Experiment freely — worst case, `down -v` and start again.  

Good luck with Ansible!
