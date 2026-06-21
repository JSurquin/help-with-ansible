---
routeAlias: 'cheatsheet-command-shell-raw'
---

# `command`, `shell` and `raw` 🔧

These are three ways to **execute text as a command** on the target — with guardrails, a shell, or "raw" execution very close to SSH.

The **`command`** module corresponds to what many call "cmd" in other tools: a command **without** a shell interpreter (no `|`, `>`, `&&` interpreted by `/bin/sh`).

---

# Comparison table

| | **`command`** | **`shell`** | **`raw`** |
| --- | --- | --- | --- |
| **Goes through a shell?** | No (executable + args) | Yes (`/bin/sh -c` on Linux) | No on Ansible side: string sent as is |
| **Pipes, `>`, `&&`, shell variables** | No (except workarounds) | Yes | Depends on what the target executes |
| **Python on target** | Required (Ansible module) | Required | **Not** required for this module |
| **Typical case** | Idempotency, simple scripts | Shell one-liners | Bootstrap, appliances, Cisco-like |

---

# `command` — without shell

Each argument is passed as is: practical to **avoid surprises** and for **idempotency** (`creates`, `removes`).

```yaml
- name: Compile if binary doesn't exist yet
  command: make install
  args:
    chdir: /opt/app/src
    creates: /usr/local/bin/myapp
```

---

# `shell` — with `/bin/sh`

Useful when you **need** the shell: redirections, pipes, `&&`, `$VAR` expansion **on remote machine side**.

```yaml
- name: Count lines and keep result in a file
  shell: grep -R "ERROR" /var/log | wc -l > /tmp/error_count.txt
  args:
    executable: /bin/bash
```

---

# `raw` — raw string (often without Python)

Sent **almost as is** on the connection: useful for **bootstrapping** a machine (installing Python), or for **equipment** that doesn't speak the usual module protocol.

```yaml
- name: Bootstrap — install minimal Python on Debian/Ubuntu
  raw: test -e /usr/bin/python3 || (apt-get update && apt-get install -y python3)
```

---

# How to choose (practical rule)

- **`command`** whenever possible: less ambiguous, better base for **`changed_when`** / **`creates`**.
- **`shell`** if you **must** have a shell interpreter (pipe, redirection, short inline script).
- **`raw`** for **bootstrap** or targets **without** classic Ansible Python environment; otherwise, prefer a dedicated module (`apt`, `package`, `user`, etc.).
