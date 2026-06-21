---
theme: ./
colorSchema: "auto"
layout: intro
highlighter: shiki
title: Ansible Help & Reference 2026
remoteAssets: false
themeConfig:
  logoHeader: "/avatar.png"
  eventLogo: "https://img2.storyblok.com/352x414/f/84560/2388x414/23d8eb4b8d/vue-amsterdam-with-name.png"
  eventUrl: "https://vuejs.amsterdam/"
---

# Ansible Help & Reference 2026

📚 Extended reference, cheatsheets, and advanced patterns for Ansible automation.

<div class="pt-12">
  <span @click="next" class="px-2 p-3 rounded cursor-pointer hover:bg-white hover:bg-opacity-10 neon-border">
    Press space for next page <carbon:arrow-right class="inline"/>
  </span>
</div>

---
layout: two-cols
routeAlias: 'sommaire'
---

# Reference table of contents 📜

<div class="flex flex-col gap-2 text-sm">
<Link to="cheatsheet">📝 Cheatsheet — quick reference</Link>
<Link to="cheatsheet-changed">📝 Cheatsheet — Ansible `changed`</Link>
<Link to="cheatsheet-command-shell-raw">📝 Cheatsheet — command, shell and raw</Link>
<Link to="cheatsheet-yaml-anchors">📝 Cheatsheet — YAML anchors (&amp; / *)</Link>
<Link to="cheatsheet-tasks">🚀 Cheat sheet — all playbook tasks</Link>
<Link to="reference-intro">☁️ Cloud inventories &amp; advanced handlers</Link>
</div>

::right::

### How to use this site

- **Quick lookup** → start with the short cheatsheet
- **Module patterns** → use the full task cheatsheet
- **Edge cases** → `changed`, `command`/`shell`/`raw`, YAML anchors
- **Cloud &amp; handlers** → extended reference section

<a target="_blank" href="https://ansible.andromed.fr">← Back to Ansible training</a>

---
routeAlias: 'cheatsheet'
---

# Ansible Cheatsheet 📝

### Quick reference for key concepts

A cheat sheet to quickly find essential concepts!

---

# Playbook

**Describes what to do and on which machines**

```yaml
- hosts: web
  tasks:
    - name: Install nginx
      apt: name=nginx state=present
```

---

# Inventory

**List of targeted machines**

```ini
[web]
192.168.1.10
```

---

# Task

**Single action executed by Ansible**

```yaml
- apt: name=nginx state=present
```

---

# Module

**Tool used by a task**

```yaml
- service: name=nginx state=started
```

---

# Role

**Reusable configuration organization**

```
roles/nginx/tasks/main.yml
```

```yaml
- apt: name=nginx state=present
```

---

# Handler

**Action triggered after a change**

```yaml
- name: restart nginx
  service: name=nginx state=restarted
```

---

# Variable

**Configurable value**

```yaml
nginx_port: 80
```

---

# Facts

**Automatic system info**

```jinja
{{ ansible_hostname }}
```

---

# Template

**Dynamically generated file**

```nginx
server {
  listen {{ nginx_port }};
}
```

---

# Vault

**Encrypted secret**

```yaml
db_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
```

---

# Happy automating! 🚀

Reference material maintained alongside the Andromed Ansible training.

---
src: './pages/reference-extracted.md'
---

---
src: './pages/cheatsheet-changed-ansible.md'
---

---
src: './pages/cheatsheet-command-shell-raw.md'
---

---
src: './pages/cheatsheet-yaml-anchors-ansible.md'
---
