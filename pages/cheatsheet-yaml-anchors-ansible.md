---
routeAlias: 'cheatsheet-yaml-anchors'
---

# YAML anchors (`&`) and aliases (`*`) in Ansible 📎

YAML allows you to **name a node** with **`&name`** and **reuse it** with **`*name`** — practical to avoid **copy-pasting** the same keys (tags, `become`, small variable blocks).

**Warning**: for large repeated logic, Ansible generally prefers **roles**, `include_tasks` / `import_tasks`, or **vars files** — anchors remain a useful **complement**.

---

# Anchor `&` and alias `*`

**`&identifier`** defines the anchor on a mapping or sequence; **`*identifier`** inserts a **copy** of that node at another location in the same file (or an included file as is).

```yaml
- hosts: webservers
  vars:
    tags_web: &tags_web
      - nginx
      - web

  tasks:
    - name: Deploy config
      template:
        src: site.conf.j2
        dest: /etc/nginx/conf.d/site.conf
      tags: *tags_web
```

---

# Merging with `<<:` (merge key)

**`<<: *anchor`** merges a **mapping** (not a simple list) into another mapping. Very useful for **`environment`**, **`vars` sub-trees**, or structures in `group_vars`.

```yaml
- hosts: webservers
  vars:
    base_env: &base_env
      LANG: C.UTF-8
      LC_ALL: C.UTF-8

  tasks:
    - name: Command with base environment + override
      command: date
      environment:
        <<: *base_env
        TZ: UTC
```

---

# Same idea in `group_vars` (DRY)

Often, a **common base** and **specific keys** per application:

```yaml
app_base: &app_base
  user: www-data
  group: www-data
  mode: "0755"

apps:
  frontend:
    <<: *app_base
    root: /var/www/frontend
  api:
    <<: *app_base
    root: /var/www/api
```

---

# Limitations and good habits

- Anchors remain **local to YAML**: hard to read if the file **grows** 

— extract rather to **`group_vars`**, **`host_vars`** or a **role**.

- **`<<:`** doesn't replace a **structured playbook**: the same sequence of 10 tasks often deserves a **`role`** or a **`block`** with `rescue`/`always`.


- For **identical task lists** on multiple hosts, the **inventory** and **roles** remain the usual source of truth.
