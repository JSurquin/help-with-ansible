# Ansible 2026 training with Slidev

![Ansible Logo](https://docs.ansible.com/ansible/latest/_static/images/logo_invert.png)

## About this course

End-to-end **Ansible 2026** training for modern infrastructure automation. This **two-day** course uses [Slidev](https://github.com/slidevjs/slidev) for an interactive learning experience.

### Learning outcomes

- Master Ansible fundamentals (playbooks, inventories, modules)
- Automate infrastructure deployment
- Manage server configuration at scale
- Apply DevOps best practices (2026)
- Integrate Ansible into CI/CD pipelines

## Course outline

### Day 1 — Ansible fundamentals (~7h)

**Morning — Core concepts**
- Introduction to Ansible and its architecture
- Inventories and host management
- Playbooks and YAML syntax
- Essential modules
- Variables and facts

**Afternoon — Hands-on**
- Beginner exercises
- Intermediate exercises (steps 1–2)
- Jinja2 templates
- Handlers and notifications

### Day 2 — Advanced Ansible (~7h)

**Morning — Going further**
- Roles and code layout
- Ansible Vault and secrets
- Collections and ecosystem
- Tags and selective execution
- CI/CD integration (GitHub Actions, GitLab)

**Afternoon — Capstone**
- Intermediate exercise (step 3)
- Advanced exercise: full production-style stack
- Knowledge quiz (QCM)
- Best practices and tuning

## Test infrastructure (Docker)

**Why Docker in this course?**

Docker is used as a **lab environment** to simulate multiple Linux hosts without heavy VMs.

### Benefits

- **10 Ubuntu “servers”** in about 30 seconds (once images are warm)
- **Lightweight** compared to full VMs
- **Realistic**: Ansible drives containers like regular hosts (with `community.docker`)
- **Disposable**: break things and rebuild quickly
- **No cloud bill** for the default lab

### Lab topology (conceptual)

```
┌─────────────────────────────────────────┐
│      Ansible control node               │
│      (your laptop / workstation)        │
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
│ x3    │   │ x2    │   │ x3     │
└───────┘   └───────┘   └────────┘
```

**10 Ubuntu containers** grouped as:

- 3 web servers  
- 2 database servers  
- 3 app servers  
- 2 monitoring hosts  

(Exact names and wiring match `inventory-lab.yml` and `docker-compose-lab.yml`.)

## Prerequisites

### Software

- **Docker** and **Docker Compose** (for the lab)
- **Python 3.8+**
- **Ansible 2.15+** (via `pip` is fine)
- **Git**
- A code editor (VS Code is a good default)

### Prior knowledge

- Basic Linux (shell, SSH)
- A little YAML
- General client/server and networking ideas
- **No prior Ansible experience required**

## Quick start

### 1. Clone the repository

```bash
git clone https://github.com/JSurquin/ansible.git
cd ansible
```

*(Use your fork URL if applicable.)*

### 2. Install Ansible

```bash
# pip (recommended)
python3 -m pip install --user ansible

ansible --version

ansible-galaxy collection install community.general ansible.posix community.docker
```

### 3. Start the Docker lab

```bash
docker-compose -f docker-compose-lab.yml up -d

docker ps

ansible -i inventory-lab.yml all -m ping
```

For a deeper walkthrough, see **[LAB-SETUP.md](./LAB-SETUP.md)**.

### 4. Run the Slidev deck

```bash
pnpm install --frozen-lockfile

pnpm run dev
```

Open **http://localhost:3030**.

## Repository layout

```
ansible/
├── slides.md                    # Main Slidev entry
├── pages/                       # Slide content (imported from slides.md)
│   ├── ansible.md               # Core Ansible theory
│   ├── 14-exercices-ansible.md  # Guided exercises
│   └── ansible-qcm.md           # End-of-course quiz
├── exemples/                    # Progressive runnable samples
├── correction/                  # Reference solution (group exercise)
├── docker-compose-lab.yml       # Lab stack (10 containers)
├── inventory-lab.yml          # Lab inventory
├── LAB-SETUP.md                # Lab guide
├── layouts/                    # Custom Slidev layouts
├── components/                 # Vue components
└── public/                     # Static assets
```

## Hands-on exercises

Three progressive tracks:

### Beginner

- Lab connectivity and first playbook
- Core ad-hoc and playbook commands

### Intermediate

- Variables and templates
- Docker-oriented patterns where relevant
- Role authoring basics

### Advanced

- Production-style layout (e.g. Nginx + app + data tier concepts)
- Backup / monitoring patterns (as shown in materials)
- Multi-environment conventions and Vault

## End-of-course quiz

**25 questions** in `pages/ansible-qcm.md`, aligned with the modules (fundamentals through Vault and control flow).

## Slide deck features

- Modern, responsive layout
- Automatic light/dark theming
- Markdown + Vue (Slidev)
- Shiki syntax highlighting
- Mermaid diagrams
- Images / GIFs
- PDF export (`pnpm run export`)
- Cross-slide navigation

## Extra resources

### Official docs

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Tips and best practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)

### Collections you will touch

- [community.general](https://galaxy.ansible.com/ui/repo/published/community/general/)
- [community.docker](https://galaxy.ansible.com/ui/repo/published/community/docker/)
- [ansible.posix](https://galaxy.ansible.com/ui/repo/published/ansible/posix/)

### Tooling

- [Ansible Lint](https://github.com/ansible/ansible-lint)
- [Molecule](https://molecule.readthedocs.io/)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html)

## Useful commands

### Slides

```bash
pnpm run dev        # dev server
pnpm run build      # production build
pnpm run export     # PDF export
pnpm run preview    # preview built site
```

### Lab

```bash
docker-compose -f docker-compose-lab.yml up -d

ansible -i inventory-lab.yml all -m ping

ansible-inventory -i inventory-lab.yml --graph

docker-compose -f docker-compose-lab.yml down
```

## Troubleshooting

### Ansible cannot reach containers

```bash
docker ps | grep ansible-lab

docker exec ansible-lab-web01 python3 --version

ansible-galaxy collection install community.docker
```

### Slidev issues

```bash
rm -rf node_modules .slidev
pnpm install
pnpm run dev
```

## Trainer

**Jimmylan Surquin**

- Founder, [Andromed](https://www.andromed.fr/)
- Lille, France
- YouTube: [jimmylansrq](https://www.youtube.com/channel/jimmylansrq)
- Site: [jimmylan.fr](https://jimmylan.fr)

## License

MIT

---

**Ready to automate with Ansible?** Start the lab, open the slides, and work through the examples in order.
