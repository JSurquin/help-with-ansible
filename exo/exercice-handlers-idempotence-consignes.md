# Exercise — Handlers and idempotence

## Objective

Write an **Ansible playbook** that updates a **configuration file** on a lab host and runs a **follow-up action** (reload, restart, or other business logic) **only when that file actually changed**. On the **second run** of the same playbook, with no input changes, that follow-up action must **not** behave like the first run.

**Estimated duration**: 45 to 60 minutes.

---

## Prerequisites

- Repository lab started:

```bash
docker compose -f docker-compose-lab.yml up -d
```

- Container **`ansible-lab-web01`** reachable (as in other “docker connection” exercises).
- Ansible installed locally.

---

## Reminders (intentionally short)

- Ansible documentation describes named blocks executed **at the end of the play** when a task **notifies** them — look for the appropriate keyword in the *Handlers* section.
- **Idempotence** means a new run without context changes does not redo unnecessary work: well-used modules often report `ok` rather than `changed` when the target state is already reached.

---

## Implementation constraints

1. Target **at least one** lab host (you may use only one to keep the final playbook summary easy to read).
2. The deployed file must **depend on at least one variable** (inventory, `group_vars`, `host_vars`, or extra-vars).
3. Use a **standard** Ansible mechanism to chain an action **after** the file changes — not two independent tasks with no cause-and-effect link.
4. Demonstrate **idempotence yourself**: **two consecutive runs** of the same playbook, changing nothing in between, must show **`changed=0`** on the relevant host in the final summary (or an equivalent clear outcome if you have several tasks).
5. Provide an **observable** way (log file, message, service, etc.) to confirm the follow-up action **did not run again** on the second pass, while it **did run** on the first.

---

## Bonus (optional)

- Third run: change a variable value (for example via command-line **extra-vars**) so the deployed file content changes; the follow-up action must **run again**.

---

## Deliverables

- An inventory (or excerpt) consistent with the lab.
- A playbook (optionally `templates/` or `group_vars/` files).
- A short note for yourself (or the trainer) explaining how you verify points 4 and 5.

Reference solution: `exo/exercice-handlers-idempotence-correction.md` (open after your attempt).
