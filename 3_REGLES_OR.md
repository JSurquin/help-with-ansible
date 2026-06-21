# 🎯 The 3 Golden Rules — Ansible 2026

## Never forget the essentials

---

## 1️⃣ VARIABLES: precedence (weakest to strongest)

```
┌─────────────────────────────────────────────────────────────┐
│                    VARIABLE PRECEDENCE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. role defaults/     📦 Role default config              │
│     (weakest)             "User CAN change"                 │
│                                                             │
│  2. group_vars/        🌍 Environment config               │
│                           "dev vs prod"                     │
│                                                             │
│  3. playbook vars:     📝 Config in the play               │
│                           "One-off"                         │
│                                                             │
│  4. role vars/         🔒 Role constants                   │
│     (strong)              "MUST NOT change"               │
│                           ⚠️ Stronger than group_vars!      │
│                                                             │
│  5. extra-vars (-e)    👑 TOTAL override                   │
│     (strongest)           "Overrides EVERYTHING"          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 💡 Mnemonic: "DGPRE"

**D**efaults → **G**roup_vars → **P**laybook → **R**ole vars → **E**xtra-vars

### ⚠️ Common trap

```yaml
# group_vars/production.yml
nginx_user: nginx  # I want to change the user

# roles/nginx/vars/main.yml
nginx_user: www-data  # ⚠️ WINS because vars/ > group_vars!

# Result: www-data (not nginx)
```

**Fix**: Put `nginx_user` in `defaults/` instead of `vars/`

### ✅ Rule to remember

- **defaults/** = What the user **CAN** change (ports, configs)
- **vars/** = What the user **MUST NOT** change (paths, packages)
- **If unsure** → put it in **defaults/** (more flexible)

---

## 2️⃣ HANDLERS: idempotence is the key

```
┌─────────────────────────────────────────────────────────────┐
│               WHEN A HANDLER FIRES                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  UNIQUE condition: changed: true                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1st run                                            │   │
│  │  ──────────────                                     │   │
│  │  TASK [Config nginx] *** changed: true              │   │
│  │  RUNNING HANDLER [restart nginx] *** ✅             │   │
│  │                                                     │   │
│  │  2nd run (same file)                                │   │
│  │  ───────────────────────────────                    │   │
│  │  TASK [Config nginx] *** ok (no changed)            │   │
│  │  (no handler) ✅ THAT IS EXPECTED!                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  💡 "If nothing changed, why restart?"                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 🐛 The 4 failure reasons

```
┌───┬─────────────────────────┬─────────────────────────────┐
│ # │ Problem                 │ Solution                    │
├───┼─────────────────────────┼─────────────────────────────┤
│ 1 │ Different name          │ Check case and spaces       │
│   │ notify: restart nginx   │ notify = handler name       │
│   │ name: Restart nginx ❌  │ EXACTLY                     │
├───┼─────────────────────────┼─────────────────────────────┤
│ 2 │ changed: false          │ Expected!                   │
│   │ (idempotence)           │ Check if it really changed  │
├───┼─────────────────────────┼─────────────────────────────┤
│ 3 │ Playbook failed         │ --force-handlers            │
│   │ before the end          │ (run even on error)         │
├───┼─────────────────────────┼─────────────────────────────┤
│ 4 │ --check mode            │ Expected!                   │
│   │ (dry-run)               │ No execution in --check     │
└───┴─────────────────────────┴─────────────────────────────┘
```

### ✅ Rule to remember

1. **Same name**: `notify` = exact handler name (case matters!)
2. **Idempotence**: A handler SHOULD NOT fire if nothing changed
3. **End of play**: Handlers run at the END (even if notified early)
4. **Once only**: Notified 10 times = runs once

### 🧪 Idempotence test (demo)

```bash
# 1st run → changed: true → handler ✅
ansible-playbook play.yml -v | grep "RUNNING HANDLER"

# 2nd run → ok (no changed) → no handler ✅
ansible-playbook play.yml -v | grep "RUNNING HANDLER"
# No output = perfect!
```

---

## 3️⃣ ROLES: defaults/ vs vars/

```
┌─────────────────────────────────────────────────────────────┐
│                 ROLES: TWO VARIABLE TYPES                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  roles/nginx/                                               │
│  │                                                          │
│  ├── defaults/main.yml  📝 Configuration                    │
│  │   │                     • Ports                          │
│  │   │                     • Timeouts                       │
│  │   │                     • Features on/off                │
│  │   └─ ✅ CAN be overridden by group_vars                 │
│  │                                                          │
│  └── vars/main.yml      🔒 Constants                        │
│      │                     • Package name                   │
│      │                     • Service name                   │
│      │                     • Config paths                   │
│      └─ ⚠️ CANNOT be overridden (high priority)            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 📋 Decision table

```
┌────────────────────────┬──────────────┬─────────────┐
│ Variable type          │ Location     │ Example     │
├────────────────────────┼──────────────┼─────────────┤
│ Port                   │ defaults/    │ 80, 443     │
│ Domain                 │ defaults/    │ example.com │
│ Timeout                │ defaults/    │ 30s         │
│ Workers                │ defaults/    │ auto, 4     │
│ Feature on/off         │ defaults/    │ true/false  │
├────────────────────────┼──────────────┼─────────────┤
│ Package name           │ vars/        │ nginx       │
│ Service name           │ vars/        │ nginx       │
│ Config path            │ vars/        │ /etc/nginx  │
│ System user            │ vars/        │ www-data    │
│ Log paths              │ vars/        │ /var/log    │
└────────────────────────┴──────────────┴─────────────┘
```

### 🎯 Concrete examples

**✅ GOOD: customizable configuration**

```yaml
# roles/nginx/defaults/main.yml
nginx_port: 80              # ← User may want 443
nginx_worker_processes: auto # ← Depends on the server
nginx_enable_gzip: true     # ← Configurable feature
```

**✅ GOOD: system constants**

```yaml
# roles/nginx/vars/main.yml
nginx_package: nginx        # ← Never changes
nginx_service: nginx        # ← System service name
nginx_config_path: /etc/nginx/nginx.conf  # ← Fixed path
```

**❌ BAD: port in vars/**

```yaml
# roles/nginx/vars/main.yml
nginx_port: 80  # ❌ Wrong location!

# Consequence:
# group_vars/production.yml
nginx_port: 443  # ❌ Has NO EFFECT (vars/ wins)
```

### ✅ Rule to remember

**Question**: "Where should I put this variable?"

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  Should the user be able to change it?          │
│                                                 │
│         YES                    NO               │
│          ↓                      ↓               │
│     defaults/               vars/               │
│                                                 │
└─────────────────────────────────────────────────┘
```

**If unsure** → `defaults/` (more flexible, can always be overridden)

---

## 📝 Quick reference

### The 3 essential debug commands

```bash
# 1. Check which value is used
ansible -m debug -a "var=ma_variable" all

# 2. Test idempotence (2 runs)
ansible-playbook play.yml && ansible-playbook play.yml

# 3. Force handlers even on error
ansible-playbook play.yml --force-handlers
```

### The 3 most common traps

```
🪤 Trap 1: Putting a port in vars/ instead of defaults/
   → Cannot be overridden by group_vars

🪤 Trap 2: Handler name with different capitalization
   → notify: restart nginx ≠ name: Restart nginx

🪤 Trap 3: Thinking a silent handler is a bug
   → If nothing changed, it is NORMAL that it does not fire
```

---

## 🎓 The 3 phrases to say in training

### On variables
> **"role vars is stronger than group_vars — that is why we put system constants there so they are never changed by accident"**

### On handlers
> **"If a handler does not fire the 2nd time, it is not a bug — it is idempotence: nothing changed, so why restart?"**

### On roles
> **"defaults/ for what the user can change, vars/ for what they must not change. If unsure, use defaults/"**

---

## ✅ One-minute pre-training checklist

```
[ ] Docker up: cd correction && docker-compose up -d
[ ] Ansible OK: ansible --version
[ ] Idempotence test: run the same playbook twice
[ ] Prepare extra-vars demo: -e "var=value"
[ ] Have tree roles/nginx/ ready
```

---

## 🚀 Let's go!

**These 3 rules cover 80% of production issues.**

**Master them = master Ansible.**

---

**Ansible 2026 training**  
Updated: March 22, 2026
