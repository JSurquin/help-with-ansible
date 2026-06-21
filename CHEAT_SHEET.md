# 📄 Training cheat sheet — keep it handy

## 🎯 THE 3 GOLDEN RULES (DGPRE mnemonic)

```
Variable precedence (weak → strong):
D = Defaults  →  G = Group_vars  →  P = Playbook  →  R = Role vars  →  E = Extra-vars
    📦              🌍                 📝                🔒               👑
```

**Trap**: role vars > group_vars (not the other way around!)

---

## 🐛 HANDLERS: debug checklist

```
Handler not firing?
├─ 1. Same name? (case + spaces)
├─ 2. changed: true? (if false = expected)
├─ 3. Playbook finished? (otherwise --force-handlers)
└─ 4. --check mode? (no execution)
```

**Key phrase**: "If nothing changed, why restart?"

---

## 📦 ROLES: defaults/ vs vars/

```
┌─────────────────────────┬─────────────┬──────────────┐
│ Question                │ Answer      │ Location     │
├─────────────────────────┼─────────────┼──────────────┤
│ User can change it      │ YES         │ defaults/    │
│ User must not change it │ NO          │ vars/        │
│ If unsure               │ ?           │ defaults/    │
└─────────────────────────┴─────────────┴──────────────┘

Examples:
• Port, timeout, workers  → defaults/
• Package, service, paths → vars/
```

---

## 🧪 THE 3 REQUIRED DEMOS

```bash
# 1. Variables (Module 7) - 2 min
ansible-playbook play.yml -e "port=8080"

# 2. Handlers (Module 9) - 5 min
ansible-playbook play.yml -v  # 1st run → handler
ansible-playbook play.yml -v  # 2nd run → no handler

# 3. Roles (Module 10) - 3 min
tree roles/nginx/
cat roles/nginx/vars/main.yml
cat roles/nginx/defaults/main.yml
```

---

## ⏱️ MODULE TIMING

```
Module 7  : 30 min (+15 min)
Module 9  : 45 min (+25 min)
Module 10 : 60 min (+30 min)
```

---

## 💬 THE 3 KEY PHRASES

**Variables**:
> "role vars beats group_vars: protects system constants"

**Handlers**:
> "No handler on the 2nd run = idempotence, not a bug"

**Roles**:
> "defaults/ = config, vars/ = constants. If unsure → defaults/"

---

## ✅ TECHNICAL CHECKLIST (5 min)

```bash
docker ps                              # Docker OK?
ansible --version                      # Ansible OK?
cd correction && docker-compose up -d  # Infra OK?
ansible-playbook ... (2x)              # Idempotence OK?
```

---

## 📊 KEY SLIDES BY MODULE

**Module 7**: "Detailed precedence", "Summary table", "defaults/ vs vars/"
**Module 9**: "Troubleshooting", "Reason 2 (idempotence)", "Hands-on test"
**Module 10**: "Critical difference", "Apache2 example", "Summary table"

---

## 🎓 FOR LEARNERS

**Hand out at the end**: `3_REGLES_OR.md`
**Format**: PDF or Markdown
**Content**: The 3 rules + production quick reference

---

**Ansible 2026 | March 22, 2026**
