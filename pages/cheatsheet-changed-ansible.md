---
routeAlias: 'cheatsheet-changed'
---

# Cheatsheet — `changed` status in Ansible 📊

When a task is marked **changed**, Ansible signals a **corrected discrepancy** between the target's current state and the requested state (file created, service started, package installed, etc.).

The following tables summarize the most common cases.

---

# Cases where a task is `changed` (1/2)

<div class="text-xs">

| Case | Description | Example |
| --- | --- | --- |
| 🆕 **Resource creation** | A resource didn't exist and is created. | File creation with `copy`, `file`, `template` |
| ✏️ **Content modification** | A resource exists but its content changes. | Config file update |
| 🔄 **State change** | The requested state differs from current state. | `state: started` on a stopped service |
| 📦 **Package installation** | A package is installed (or updated). | `apt install nginx` |
| ❌ **Deletion** | A resource existed and is deleted. | `state: absent` |
| 🔐 **Permission modification** | Rights, owner or group change. | `mode: 0755` |
| 🔗 **Link change** | A symbolic link is created or modified. | `state: link` |
| 🧩 **Different template rendering** | Template rendering differs from existing file. | `template` with variables |

</div>

---

# Cases where a task is `changed` (2/2)

| Case | Description | Example |
| --- | --- | --- |
| ⚙️ **Command with effect** | A command modifies something. | `command`, `shell` without condition |
| 🔁 **Handler triggered** | A task notifies a handler after a change. | `notify: restart nginx` |
| 📂 **Archive extraction** | Archive extracted and files created/modified. | `unarchive` |
| 🌐 **Git clone/pull** | Repository cloned or updated. | `git` module |
| 📥 **File download** | File downloaded and different. | `get_url` |
| 🧪 **Forced changed** | `changed_when: true` | Manual override |
| 🚫 **Not idempotent** | Non-idempotent module/script. | Custom script |

---

# Special cases (often misunderstood)

| Case | Behavior |
| --- | --- |
| **`command` / `shell`** | Always **changed** except if `creates` or `removes`. |
| **Check mode** | Can predict **changed** without executing. |
| **`register`** | Doesn't directly influence **changed**. |
| **`changed_when: false`** | Forces **ok** even if modified. |
| **`diff` enabled** | Allows seeing why it's **changed**. |

---

# Example — `template` + handler

If template rendering **differs** from the file on the machine → **changed**, then the handler executes (often **changed** too: restart / reload).

```yaml
- name: Deploy nginx.conf
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Reload nginx

handlers:
  - name: Reload nginx
    ansible.builtin.service:
      name: nginx
      state: reloaded
```

---

# Example — `command` and idempotency (`creates`)

Without `creates`, the task would often be **changed** every time. Here: **ok** if `/tmp/app.tgz` already exists.

```yaml
- name: Download archive if it doesn't exist
  ansible.builtin.command: curl -fsSL -o /tmp/app.tgz https://example.com/app.tgz
  args:
    creates: /tmp/app.tgz
```

---

# Example — `register` + `changed_when`

`register` doesn't change status by itself: we **recalculate** with `changed_when` when the task should count as a change (useful with `command` / scripts).

```yaml
- name: Check version presence
  ansible.builtin.command: nginx -v
  register: nginx_version
  changed_when: "'1.26' not in nginx_version.stderr | default('')"
```
