# Solution — Handlers and idempotence

## Location

Reference Ansible project: **`exo/correction-handlers-idempotence/`**

| File | Role |
|--------|------|
| `inventory.yml` | Group `handler_lab` → `ansible-lab-web01` (`docker` connection) |
| `group_vars/handler_lab.yml` | Variable `lab_banner` for the template |
| `templates/lab-handlers.conf.j2` | Generated configuration file |
| `playbook.yml` | `template` task + `notify` + `handlers` section |
| `test.sh` | Automated validation (3 playbook runs) |

---

## Principle

- The **`ansible.builtin.template`** task deploys `/etc/lab-handlers-test.conf` and **notifies** the handler only when Ansible considers the file changed.
- The handler **appends** a timestamped line to `/tmp/lab_handler_audit.log`: visible proof it ran.
- **2nd run**: file unchanged → no notification → no extra line; `changed=0` on the host in the summary (unless the student added other non-idempotent tasks).
- **3rd run** (automated test): `-e lab_banner=...` changes the template output → new notification → second line in the log.

`gather_facts: false` keeps the playbook minimal; the handler uses the target shell date.

---

## Test executed

From the repository root, with the lab already started:

```bash
docker compose -f docker-compose-lab.yml up -d
cd exo/correction-handlers-idempotence
chmod +x test.sh   # if needed
./test.sh
```

Result during preparation: **all tests OK** (handler on 1st and 3rd run, not on 2nd; log with 1 then 2 lines).

---

## Files (copy)

### `inventory.yml`

```yaml
---
# Single lab node to simplify reading the summary and handler log.
all:
  vars:
    ansible_connection: docker
    ansible_user: root
    ansible_python_interpreter: /usr/bin/python3
  children:
    handler_lab:
      hosts:
        lab01:
          ansible_host: ansible-lab-web01
```

### `group_vars/handler_lab.yml`

```yaml
---
lab_banner: "lab-handlers-v1"
```

### `templates/lab-handlers.conf.j2`

```
# {{ ansible_managed }}
# Demo file for handlers + idempotence
LAB_BANNER={{ lab_banner }}
```

### `playbook.yml`

```yaml
---
# Minimal playbook: one file resource + one handler (proof in /tmp).
- name: Handlers and idempotence lab
  hosts: handler_lab
  gather_facts: false

  tasks:
    - name: Deploy configuration from template
      ansible.builtin.template:
        src: lab-handlers.conf.j2
        dest: /etc/lab-handlers-test.conf
        mode: "0644"
      notify: Log handler execution

  handlers:
    - name: Log handler execution
      ansible.builtin.shell:
        cmd: 'printf "%s handler-fired\n" "$(date -Iseconds)" >> /tmp/lab_handler_audit.log'
        executable: /bin/bash
```

---

## Teaching variants

- Replace the handler with **`systemctl reload nginx`** (on a VM with systemd) or a real reload of a service already covered in the course.
- Extend to **multiple hosts**: each machine has its own `/tmp/lab_handler_audit.log`; adapt the test script to loop over containers.
- Have students write a minimal **`test.sh`** replicating the three-pass logic (cleanup, run, assertions).
