# Group exercise — modules (Apache2 / Nginx)

## Exercise statement

### 🎯 Exercise objective

Set up an Ansible infrastructure composed of 4 servers:

- 2 Apache2 servers
- 2 Nginx servers

Each server type:

- uses its own playbook
- is defined in a dedicated inventory
- has its specific templates
- triggers its specific handlers

---

## Group exercise — modules

```mermaid
flowchart TB
    %% Styles
    classDef inventory fill:#E3F2FD,stroke:#1E88E5,color:#0D47A1
    classDef playbook fill:#E8F5E9,stroke:#43A047,color:#1B5E20
    classDef role fill:#FFFDE7,stroke:#F9A825,color:#F57F17
    classDef template fill:#FCE4EC,stroke:#D81B60,color:#880E4F
    classDef handler fill:#F3E5F5,stroke:#8E24AA,color:#4A148C
    classDef server fill:#ECEFF1,stroke:#455A64,color:#263238

    %% Inventories
    INV_A[Inventory apache2.yml]:::inventory
    INV_N[Inventory nginx.yml]:::inventory

    %% Playbooks
    PB_A[Playbook play-apache2.yml]:::playbook
    PB_N[Playbook play-nginx.yml]:::playbook

    %% Roles
    ROLE_A[Role apache2]:::role
    ROLE_N[Role nginx]:::role

    %% Templates
    TPL_A1[apache2.conf.j2]:::template
    TPL_A2[index.html.j2]:::template
    TPL_N1[nginx.conf.j2]:::template
    TPL_N2[index.html.j2]:::template

    %% Handlers
    H_A[Restart apache2]:::handler
    H_N[Restart nginx]:::handler

    %% Servers
    S1[apache1]:::server
    S2[apache2]:::server
    S3[nginx1]:::server
    S4[nginx2]:::server

    %% Links
    INV_A --> PB_A
    INV_N --> PB_N

    PB_A --> ROLE_A
    PB_N --> ROLE_N

    ROLE_A --> TPL_A1
    ROLE_A --> TPL_A2
    ROLE_A --> H_A

    ROLE_N --> TPL_N1
    ROLE_N --> TPL_N2
    ROLE_N --> H_N

    INV_A --> S1
    INV_A --> S2

    INV_N --> S3
    INV_N --> S4
```

---

## If you need help with the exercise structure:

```bash
group_vars/
└── all.yml

inventories/
├── apache2.yml
└── nginx.yml

playbooks/
├── play-apache2.yml
└── play-nginx.yml

roles/
├── apache2/
│   ├── tasks/
│   │   └── main.yml
│   ├── handlers/
│   │   └── main.yml
│   ├── templates/
│   │   ├── apache2.conf.j2
│   │   └── index.html.j2
│   └── vars/
│       └── main.yml
│
└── nginx/
    ├── tasks/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── templates/
    │   ├── nginx.conf.j2
    │   └── index.html.j2
    └── vars/
        └── main.yml
```
